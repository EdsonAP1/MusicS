import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/constants/app_dimensions.dart';
import 'package:flutter_application_1/core/utils/audio_helpers.dart';
import 'package:flutter_application_1/providers/audio_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/providers/favorites_provider.dart';
import 'package:flutter_application_1/widgets/glassmorphism_container.dart';
import 'package:flutter_application_1/widgets/audio_visualizer.dart';

/// Full-screen music player page with wallpaper background
class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioCtrl = ref.watch(audioControllerProvider);
    final themeState = ref.watch(themeProvider);
    final favorites = ref.watch(favoritesProvider);
    final song = audioCtrl.currentSong;

    if (song == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isFav = favorites.contains(song.id);
    final qualityDesc = AudioHelpers.getQualityDescription(
      song.filePath, song.bitrate, song.sampleRate,
    );
    final qualityLabel = AudioHelpers.getQualityLabel(song.filePath, song.bitrate);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          _PlayerBackground(
            wallpaperPath: themeState.wallpaperPath,
            songId: song.id,
            accentColor: themeState.accentColor,
          ),

          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _TopBar(context: context),

                const Spacer(flex: 1),

                // Album art
                _AlbumArt(
                  songId: song.id,
                  customArtworkPath: song.customArtworkPath,
                  accentColor: themeState.accentColor,
                ).animate().fadeIn(duration: 500.ms).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                ),

                const Spacer(flex: 1),

                // Song info + controls (glassmorphism card)
                GlassmorphismContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  borderRadius: 28,
                  blur: 30,
                  opacity: 0.12,
                  child: Column(
                    children: [
                      // Title & artist
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      // Quality badge
                      if (qualityDesc.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _qualityColor(qualityLabel).withValues(alpha: 0.2),
                            border: Border.all(
                              color: _qualityColor(qualityLabel).withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            qualityDesc,
                            style: TextStyle(
                              color: _qualityColor(qualityLabel),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Progress bar
                      StreamBuilder<Duration>(
                        stream: audioCtrl.player.positionStream,
                        builder: (context, posSnap) {
                          final position = posSnap.data ?? Duration.zero;
                          final duration = audioCtrl.player.duration ?? Duration.zero;
                          final buffered = audioCtrl.player.bufferedPosition;

                          return ProgressBar(
                            progress: position,
                            total: duration,
                            buffered: buffered,
                            progressBarColor: themeState.playerColor,
                            baseBarColor: Colors.white.withValues(alpha: 0.15),
                            bufferedBarColor: themeState.playerColor.withValues(alpha: 0.3),
                            thumbColor: themeState.playerColor,
                            thumbRadius: 6,
                            barHeight: 3,
                            timeLabelTextStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            onSeek: (duration) => audioCtrl.seek(duration),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Main controls
                      _MainControls(
                        audioCtrl: audioCtrl,
                        playerColor: themeState.playerColor,
                      ),

                      const SizedBox(height: 12),

                      // Bottom controls (volume, favorite)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Shuffle
                          IconButton(
                            icon: Icon(
                              Icons.shuffle_rounded,
                              color: audioCtrl.isShuffled
                                  ? themeState.playerColor
                                  : Colors.white.withValues(alpha: 0.5),
                              size: 22,
                            ),
                            onPressed: () => audioCtrl.toggleShuffle(),
                          ),
                          // Repeat
                          IconButton(
                            icon: Icon(
                              audioCtrl.repeatMode == MusicRepeatMode.one
                                  ? Icons.repeat_one_rounded
                                  : Icons.repeat_rounded,
                              color: audioCtrl.repeatMode != MusicRepeatMode.off
                                  ? themeState.playerColor
                                  : Colors.white.withValues(alpha: 0.5),
                              size: 22,
                            ),
                            onPressed: () => audioCtrl.cycleRepeatMode(),
                          ),
                          // Volume icon
                          IconButton(
                            icon: Icon(
                              Icons.volume_up_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 22,
                            ),
                            onPressed: () => _showVolumeSlider(context, audioCtrl, themeState),
                          ),
                          // Favorite
                          IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFav ? AppColors.primaryPink : Colors.white.withValues(alpha: 0.7),
                              size: 22,
                            ),
                            onPressed: () =>
                                ref.read(favoritesProvider.notifier).toggleFavorite(song.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 12),

                // Visualizer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: StreamBuilder<PlayerState>(
                    stream: audioCtrl.player.playerStateStream,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data?.playing ?? false;
                      return AudioVisualizerWidget(
                        type: themeState.visualizerType,
                        isPlaying: isPlaying,
                        color: themeState.playerColor,
                        height: AppDimensions.visualizerHeight,
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _qualityColor(String label) {
    switch (label) {
      case 'Lossless':
        return AppColors.qualityLossless;
      case 'High':
        return AppColors.qualityHigh;
      case 'Standard':
        return AppColors.qualityStandard;
      default:
        return AppColors.qualityBasic;
    }
  }

  void _showVolumeSlider(BuildContext context, AudioController audioCtrl, ThemeState themeState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: 100,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E3A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.volume_down_rounded, color: Colors.white.withValues(alpha: 0.7)),
              Expanded(
                child: StreamBuilder<double>(
                  stream: audioCtrl.player.volumeStream,
                  builder: (context, snapshot) {
                    return Slider(
                      value: snapshot.data ?? 1.0,
                      onChanged: (v) => audioCtrl.player.setVolume(v),
                      activeColor: themeState.playerColor,
                      inactiveColor: Colors.white.withValues(alpha: 0.15),
                    );
                  },
                ),
              ),
              Icon(Icons.volume_up_rounded, color: Colors.white.withValues(alpha: 0.7)),
            ],
          ),
        );
      },
    );
  }
}

/// Player background — custom wallpaper or artwork blur
class _PlayerBackground extends StatelessWidget {
  final String? wallpaperPath;
  final String songId;
  final Color accentColor;

  const _PlayerBackground({
    this.wallpaperPath,
    required this.songId,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (wallpaperPath != null && File(wallpaperPath!).existsSync()) {
      return Image.file(
        File(wallpaperPath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Default: gradient with artwork hint
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromColor(accentColor).withLightness(0.15).toColor(),
            const Color(0xFF0A0A0F),
            HSLColor.fromColor(accentColor).withLightness(0.08).toColor(),
          ],
        ),
      ),
      child: QueryArtworkWidget(
        id: int.tryParse(songId) ?? 0,
        type: ArtworkType.AUDIO,
        artworkWidth: double.infinity,
        artworkHeight: double.infinity,
        artworkFit: BoxFit.cover,
        artworkBorder: BorderRadius.zero,
        nullArtworkWidget: const SizedBox.expand(),
        artworkQuality: FilterQuality.low,
      ),
    );
  }
}

/// Top bar with back button
class _TopBar extends StatelessWidget {
  final BuildContext context;
  const _TopBar({required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            color: Colors.white.withValues(alpha: 0.8),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'NOW PLAYING',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            color: Colors.white.withValues(alpha: 0.8),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

/// Album artwork display
class _AlbumArt extends StatelessWidget {
  final String songId;
  final String? customArtworkPath;
  final Color accentColor;

  const _AlbumArt({
    required this.songId,
    this.customArtworkPath,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.7;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildArtwork(size),
    );
  }

  Widget _buildArtwork(double size) {
    if (customArtworkPath != null && File(customArtworkPath!).existsSync()) {
      return Image.file(
        File(customArtworkPath!),
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    }

    return QueryArtworkWidget(
      id: int.tryParse(songId) ?? 0,
      type: ArtworkType.AUDIO,
      artworkBorder: BorderRadius.circular(24),
      artworkWidth: size,
      artworkHeight: size,
      artworkFit: BoxFit.cover,
      artworkQuality: FilterQuality.high,
      nullArtworkWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: AppColors.accentGradient(accentColor),
        ),
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white.withValues(alpha: 0.6),
          size: size * 0.35,
        ),
      ),
    );
  }
}

/// Main playback controls (prev, rewind, play/pause, forward, next)
class _MainControls extends StatelessWidget {
  final AudioController audioCtrl;
  final Color playerColor;

  const _MainControls({
    required this.audioCtrl,
    required this.playerColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioCtrl.player.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Previous
            _ControlButton(
              icon: Icons.skip_previous_rounded,
              size: 32,
              onTap: () => audioCtrl.previous(),
            ),
            // Rewind 10s
            _ControlButton(
              icon: Icons.replay_10_rounded,
              size: 28,
              onTap: () {
                final newPos = audioCtrl.player.position - const Duration(seconds: 10);
                audioCtrl.seek(newPos < Duration.zero ? Duration.zero : newPos);
              },
            ),
            // Play/Pause (large)
            GestureDetector(
              onTap: () => audioCtrl.togglePlayPause(),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: playerColor,
                  boxShadow: [
                    BoxShadow(
                      color: playerColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            // Forward 10s
            _ControlButton(
              icon: Icons.forward_10_rounded,
              size: 28,
              onTap: () {
                final dur = audioCtrl.player.duration ?? Duration.zero;
                final newPos = audioCtrl.player.position + const Duration(seconds: 10);
                audioCtrl.seek(newPos > dur ? dur : newPos);
              },
            ),
            // Next
            _ControlButton(
              icon: Icons.skip_next_rounded,
              size: 32,
              onTap: () => audioCtrl.next(),
            ),
          ],
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size),
      color: Colors.white.withValues(alpha: 0.9),
      onPressed: onTap,
    );
  }
}
