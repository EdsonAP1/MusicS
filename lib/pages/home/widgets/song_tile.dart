import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/constants/app_dimensions.dart';
import 'package:flutter_application_1/core/utils/audio_helpers.dart';
import 'package:flutter_application_1/data/models/song_model.dart';

/// Individual song list tile with artwork, info, and controls
class SongTile extends StatelessWidget {
  final SongData song;
  final bool isFavorite;
  final bool isPlaying;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const SongTile({
    super.key,
    required this.song,
    required this.isFavorite,
    required this.isPlaying,
    required this.accentColor,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qualityLabel = AudioHelpers.getQualityLabel(song.filePath, song.bitrate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimensions.songTileHeight,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          color: isPlaying
              ? accentColor.withValues(alpha: isDark ? 0.15 : 0.08)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Album art
            Hero(
              tag: 'artwork_${song.id}',
              child: Container(
                width: AppDimensions.albumArtSmall,
                height: AppDimensions.albumArtSmall,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isPlaying
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: QueryArtworkWidget(
                  id: int.tryParse(song.id) ?? 0,
                  type: ArtworkType.AUDIO,
                  artworkBorder: BorderRadius.circular(12),
                  artworkWidth: AppDimensions.albumArtSmall,
                  artworkHeight: AppDimensions.albumArtSmall,
                  artworkFit: BoxFit.cover,
                  nullArtworkWidget: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppColors.accentGradient(accentColor),
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Song info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isPlaying ? accentColor : null,
                          fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      // Quality badge
                      if (qualityLabel == 'Lossless')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: AppColors.qualityLossless.withValues(alpha: 0.15),
                          ),
                          child: Text(
                            song.format ?? 'HQ',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.qualityLossless,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          '${song.artist} • ${AudioHelpers.formatMs(song.duration)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Playing indicator or favorite button
            if (isPlaying)
              _PlayingIndicator(color: accentColor)
            else
              GestureDetector(
                onTap: onFavoriteTap,
                child: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? AppColors.primaryPink : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Animated playing indicator (3 bars)
class _PlayingIndicator extends StatefulWidget {
  final Color color;
  const _PlayingIndicator({required this.color});

  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 150),
      )..repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controllers[i],
            builder: (_, c) {
              return Container(
                width: 3,
                height: 6 + _controllers[i].value * 14,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
