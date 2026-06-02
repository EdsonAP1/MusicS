import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/constants/app_dimensions.dart';
import 'package:flutter_application_1/providers/audio_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/pages/player/player_page.dart';

/// Persistent mini player that shows at the bottom of the screen
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioCtrl = ref.watch(audioControllerProvider);
    final themeState = ref.watch(themeProvider);
    final song = audioCtrl.currentSong;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, a, b) => const PlayerPage(),
            transitionsBuilder: (_, animation, a2, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        height: AppDimensions.miniPlayerHeight,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          color: isDark
              ? AppColors.darkCard.withValues(alpha: 0.95)
              : AppColors.lightCard.withValues(alpha: 0.95),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeState.accentColor.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            // Progress indicator (thin line at top)
            StreamBuilder<Duration>(
              stream: audioCtrl.player.positionStream,
              builder: (context, posSnap) {
                final pos = posSnap.data ?? Duration.zero;
                final dur = audioCtrl.player.duration ?? Duration.zero;
                final progress = dur.inMilliseconds > 0
                    ? pos.inMilliseconds / dur.inMilliseconds
                    : 0.0;
                return Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(themeState.accentColor),
                    minHeight: 2,
                  ),
                );
              },
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Artwork
                    Container(
                      width: AppDimensions.albumArtTiny,
                      height: AppDimensions.albumArtTiny,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: QueryArtworkWidget(
                        id: int.tryParse(song.id) ?? 0,
                        type: ArtworkType.AUDIO,
                        artworkBorder: BorderRadius.circular(10),
                        artworkWidth: AppDimensions.albumArtTiny,
                        artworkHeight: AppDimensions.albumArtTiny,
                        artworkFit: BoxFit.cover,
                        nullArtworkWidget: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: AppColors.accentGradient(themeState.accentColor),
                          ),
                          child: const Icon(Icons.music_note, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & artist
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),

                    // Controls
                    StreamBuilder<PlayerState>(
                      stream: audioCtrl.player.playerStateStream,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous_rounded),
                              iconSize: 24,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              onPressed: () => audioCtrl.previous(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36),
                            ),
                            GestureDetector(
                              onTap: () => audioCtrl.togglePlayPause(),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: themeState.accentColor,
                                ),
                                child: Icon(
                                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next_rounded),
                              iconSize: 24,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              onPressed: () => audioCtrl.next(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
