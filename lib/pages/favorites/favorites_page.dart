import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/utils/audio_helpers.dart';
import 'package:flutter_application_1/data/models/song_model.dart';
import 'package:flutter_application_1/providers/audio_provider.dart';
import 'package:flutter_application_1/providers/favorites_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';

/// Favorites page — displays all favorited songs
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final audioCtrl = ref.watch(audioControllerProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get favorite songs from all songs
    final favoriteSongs = audioCtrl.allSongs
        .where((s) => favoriteIds.contains(s.id))
        .toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [AppColors.primaryPink, AppColors.primaryOrange],
                          ),
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'favorites'.tr(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            '${favoriteSongs.length} ${'songs'.tr().toLowerCase()}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (favoriteSongs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    // Play all button
                    GestureDetector(
                      onTap: () {
                        if (favoriteSongs.isNotEmpty) {
                          audioCtrl.playSong(favoriteSongs.first, playlist: favoriteSongs);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: AppColors.accentGradient(themeState.accentColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              'play_all'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Empty state
          if (favoriteSongs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 80,
                      color: AppColors.primaryPink.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'no_favorites'.tr(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),

          // Favorite songs list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = favoriteSongs[index];
                final isPlaying = audioCtrl.currentSong?.id == song.id;

                return Dismissible(
                  key: Key(song.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.primaryRed.withValues(alpha: 0.2),
                    child: const Icon(Icons.delete_rounded, color: AppColors.primaryRed),
                  ),
                  onDismissed: (_) {
                    ref.read(favoritesProvider.notifier).removeFavorite(song.id);
                  },
                  child: _FavoriteTile(
                    song: song,
                    isPlaying: isPlaying,
                    accentColor: themeState.accentColor,
                    onTap: () => audioCtrl.playSong(song, playlist: favoriteSongs),
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: 50 * index.clamp(0, 10)),
                        duration: 300.ms,
                      ),
                );
              },
              childCount: favoriteSongs.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final SongData song;
  final bool isPlaying;
  final Color accentColor;
  final VoidCallback onTap;

  const _FavoriteTile({
    required this.song,
    required this.isPlaying,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 52,
        height: 52,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: QueryArtworkWidget(
          id: int.tryParse(song.id) ?? 0,
          type: ArtworkType.AUDIO,
          artworkBorder: BorderRadius.circular(12),
          nullArtworkWidget: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: AppColors.accentGradient(accentColor),
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 24),
          ),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPlaying ? accentColor : null,
          fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${song.artist} • ${AudioHelpers.formatMs(song.duration)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isPlaying
          ? Icon(Icons.equalizer_rounded, color: accentColor)
          : Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 20),
      onTap: onTap,
    );
  }
}
