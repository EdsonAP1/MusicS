import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/data/models/song_model.dart';
import 'package:flutter_application_1/data/models/song_model.g.dart';
import 'package:flutter_application_1/data/models/playlist_model.dart';
import 'package:flutter_application_1/data/models/playlist_model.g.dart';

/// Central Hive database service — initializes boxes and provides access
class HiveService {
  HiveService._();

  static const String _songsBox = 'songs';
  static const String _favoritesBox = 'favorites';
  static const String _playlistsBox = 'playlists';
  static const String _settingsBox = 'settings';

  static late Box<SongData> songs;
  static late Box<String> favorites;
  static late Box<PlaylistData> playlists;
  static late Box settings;

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(SongDataAdapter());
    Hive.registerAdapter(PlaylistDataAdapter());

    // Open boxes
    songs = await Hive.openBox<SongData>(_songsBox);
    favorites = await Hive.openBox<String>(_favoritesBox);
    playlists = await Hive.openBox<PlaylistData>(_playlistsBox);
    settings = await Hive.openBox(_settingsBox);
  }

  // ═══════════════════════════════════════════
  // SETTINGS HELPERS
  // ═══════════════════════════════════════════

  static bool get isDarkMode => settings.get('isDarkMode', defaultValue: true);
  static set isDarkMode(bool value) => settings.put('isDarkMode', value);

  static String get locale => settings.get('locale', defaultValue: 'es');
  static set locale(String value) => settings.put('locale', value);

  static int get accentColorValue =>
      settings.get('accentColor', defaultValue: 0xFF7C4DFF);
  static set accentColorValue(int value) => settings.put('accentColor', value);

  static Color get accentColor => Color(accentColorValue);

  static String? get wallpaperPath => settings.get('wallpaperPath');
  static set wallpaperPath(String? value) => settings.put('wallpaperPath', value);

  static int get visualizerType => settings.get('visualizerType', defaultValue: 0);
  static set visualizerType(int value) => settings.put('visualizerType', value);

  static int get progressBarType => settings.get('progressBarType', defaultValue: 0);
  static set progressBarType(int value) => settings.put('progressBarType', value);

  static String get userName => settings.get('userName', defaultValue: 'Music Lover');
  static set userName(String value) => settings.put('userName', value);

  static String? get avatarPath => settings.get('avatarPath');
  static set avatarPath(String? value) => settings.put('avatarPath', value);

  static int get playerColorValue =>
      settings.get('playerColor', defaultValue: 0xFF7C4DFF);
  static set playerColorValue(int value) => settings.put('playerColor', value);

  static Color get playerColor => Color(playerColorValue);

  /// Clear all data
  static Future<void> clearAll() async {
    await songs.clear();
    await favorites.clear();
    await playlists.clear();
    await settings.clear();
  }
}
