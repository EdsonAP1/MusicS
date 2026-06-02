import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/utils/audio_helpers.dart';
import 'package:flutter_application_1/data/models/song_model.dart';
import 'package:flutter_application_1/providers/audio_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';

/// Search page with real-time filtering
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioCtrl = ref.watch(audioControllerProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _query.isEmpty
        ? <SongData>[]
        : audioCtrl.allSongs.where((s) {
            final q = _query.toLowerCase();
            return s.title.toLowerCase().contains(q) ||
                s.artist.toLowerCase().contains(q) ||
                s.album.toLowerCase().contains(q);
          }).toList();

    return SafeArea(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _query = val),
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'search_songs'.tr(),
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: themeState.accentColor,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child: _query.isEmpty
                ? _SearchSuggestions(accentColor: themeState.accentColor)
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 60,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'no_songs'.tr(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 160),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final song = filtered[index];
                          final isPlaying = audioCtrl.currentSong?.id == song.id;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                            leading: Container(
                              width: 48,
                              height: 48,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                              child: QueryArtworkWidget(
                                id: int.tryParse(song.id) ?? 0,
                                type: ArtworkType.AUDIO,
                                artworkBorder: BorderRadius.circular(10),
                                nullArtworkWidget: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: AppColors.accentGradient(themeState.accentColor),
                                  ),
                                  child: const Icon(Icons.music_note, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                            title: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isPlaying ? themeState.accentColor : null,
                                fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${song.artist} • ${AudioHelpers.formatMs(song.duration)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => audioCtrl.playSong(song),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  final Color accentColor;

  const _SearchSuggestions({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: accentColor.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'search_songs'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
