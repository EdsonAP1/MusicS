import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_application_1/data/models/song_model.dart';
import 'package:flutter_application_1/data/database/hive_service.dart';
import 'package:flutter_application_1/core/utils/audio_helpers.dart';

/// Repeat modes for playback
enum MusicRepeatMode { off, all, one }

/// Main audio controller — wraps just_audio and manages queue
class AudioController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<SongData> _allSongs = [];
  List<SongData> _queue = [];
  bool _isShuffled = false;
  MusicRepeatMode _repeatMode = MusicRepeatMode.off;
  bool _isLoading = false;
  bool _permissionGranted = false;

  // Getters
  AudioPlayer get player => _player;
  List<SongData> get allSongs => _allSongs;
  List<SongData> get queue => _queue;
  
  int get currentIndex => _player.currentIndex ?? -1;
  SongData? get currentSong =>
      currentIndex >= 0 && currentIndex < _queue.length
          ? _queue[currentIndex]
          : null;
          
  bool get isShuffled => _isShuffled;
  MusicRepeatMode get repeatMode => _repeatMode;
  bool get isLoading => _isLoading;
  bool get permissionGranted => _permissionGranted;
  bool get hasSong => currentSong != null;

  AudioController() {
    _init();
  }

  Future<void> _init() async {
    // Notify UI when current song automatically changes (e.g. next track)
    _player.currentIndexStream.listen((index) {
      notifyListeners();
    });
    
    // Listen for state changes (playing/paused/buffering)
    _player.playerStateStream.listen((state) {
      notifyListeners();
    });
  }

  /// Request permissions and scan device for audio files
  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check storage permission
      _permissionGranted = await _audioQuery.checkAndRequest(retryRequest: true);
      
      // Request notification permission for lock screen controls (Android 13+)
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      if (!_permissionGranted) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Query all audio files
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.DATE_ADDED,
        orderType: OrderType.DESC_OR_GREATER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      _allSongs = songs
          .where((s) => s.duration != null && s.duration! > 5000)
          .map((s) => SongData(
                id: s.id.toString(),
                title: s.title,
                artist: s.artist ?? 'Unknown Artist',
                album: s.album ?? 'Unknown Album',
                filePath: s.data,
                duration: s.duration ?? 0,
                format: AudioHelpers.getFormat(s.data),
                size: s.size,
                dateAdded: s.dateAdded,
                albumId: s.albumId,
                artistId: s.artistId,
              ))
          .toList();

      // Store in Hive cache
      for (final song in _allSongs) {
        HiveService.songs.put(song.id, song);
      }
    } catch (e) {
      debugPrint('Error loading songs: $e');
      // Try loading from cache
      _allSongs = HiveService.songs.values.toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Play a specific song
  Future<void> playSong(SongData song, {List<SongData>? playlist}) async {
    _queue = playlist ?? List.from(_allSongs);

    // Construct the ConcatenatingAudioSource for the full lockscreen controls
    final audioSource = ConcatenatingAudioSource(
      children: _queue.map((s) => AudioSource.uri(
        Uri.file(s.filePath),
        tag: MediaItem(
          id: s.id,
          title: s.title,
          artist: s.artist,
          album: s.album,
          duration: Duration(milliseconds: s.duration),
          // Optionally add artUri if you want artwork in lockscreen:
          // artUri: Uri.parse('content://media/external/audio/media/${s.id}/albumart'),
        ),
      )).toList(),
    );

    int initialIndex = _queue.indexWhere((s) => s.id == song.id);
    if (initialIndex < 0) initialIndex = 0;

    try {
      await _player.setAudioSource(audioSource, initialIndex: initialIndex);
      await _player.play();
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
  }

  /// Play from queue at index
  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    try {
      await _player.seek(Duration.zero, index: index);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing at index: $e');
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  /// Skip to next song
  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    } else if (_repeatMode == MusicRepeatMode.all) {
      await _player.seek(Duration.zero, index: 0);
    }
  }

  /// Skip to previous song (or restart if > 3s played)
  Future<void> previous() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else if (_repeatMode == MusicRepeatMode.all && _queue.isNotEmpty) {
      await _player.seek(Duration.zero, index: _queue.length - 1);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Toggle shuffle mode
  Future<void> toggleShuffle() async {
    _isShuffled = !_isShuffled;
    await _player.setShuffleModeEnabled(_isShuffled);
    if (_isShuffled) {
      await _player.shuffle();
    }
    notifyListeners();
  }

  /// Cycle repeat mode: off -> all -> one -> off
  void cycleRepeatMode() {
    switch (_repeatMode) {
      case MusicRepeatMode.off:
        _repeatMode = MusicRepeatMode.all;
        _player.setLoopMode(LoopMode.all);
        break;
      case MusicRepeatMode.all:
        _repeatMode = MusicRepeatMode.one;
        _player.setLoopMode(LoopMode.one);
        break;
      case MusicRepeatMode.one:
        _repeatMode = MusicRepeatMode.off;
        _player.setLoopMode(LoopMode.off);
        break;
    }
    notifyListeners();
  }

  /// Get artwork query widget key for on_audio_query
  int? get currentArtworkId {
    if (currentSong == null) return null;
    return int.tryParse(currentSong!.id);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// Global audio controller provider
final audioControllerProvider =
    ChangeNotifierProvider<AudioController>((ref) => AudioController());
