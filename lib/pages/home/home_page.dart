import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/constants/app_dimensions.dart';
import 'package:flutter_application_1/data/models/song_model.dart';
import 'package:flutter_application_1/providers/audio_provider.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/providers/favorites_provider.dart';
import 'package:flutter_application_1/pages/favorites/favorites_page.dart';
import 'package:flutter_application_1/pages/search/search_page.dart';
import 'package:flutter_application_1/pages/profile/profile_page.dart';
import 'package:flutter_application_1/pages/equalizer/equalizer_page.dart';
import 'package:flutter_application_1/widgets/custom_bottom_nav.dart';
import 'package:flutter_application_1/pages/home/widgets/mini_player.dart';
import 'package:flutter_application_1/pages/home/widgets/song_tile.dart';

/// Main home page with tabs: Home, Favorites, Search, Profile
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    // Load songs on first open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioControllerProvider).loadSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final audioCtrl = ref.watch(audioControllerProvider);

    final pages = [
      _HomeTab(audioCtrl: audioCtrl),
      const FavoritesPage(),
      const SearchPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Page content
          IndexedStack(
            index: _currentTab,
            children: pages,
          ),

          // Mini player (above bottom nav)
          if (audioCtrl.hasSong)
            Positioned(
              bottom: AppDimensions.bottomNavHeight,
              left: 0,
              right: 0,
              child: const MiniPlayer()
                  .animate()
                  .slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentTab,
        accentColor: themeState.accentColor,
        onTap: (index) => setState(() => _currentTab = index),
      ),
    );
  }
}

/// Home tab content — shows all songs with header
class _HomeTab extends ConsumerWidget {
  final AudioController audioCtrl;

  const _HomeTab({required this.audioCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeState = ref.watch(themeProvider);
    final favorites = ref.watch(favoritesProvider);

    if (audioCtrl.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!audioCtrl.permissionGranted) {
      return _PermissionView(audioCtrl: audioCtrl);
    }

    if (audioCtrl.allSongs.isEmpty) {
      return _EmptyView();
    }

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          floating: true,
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: AppColors.accentGradient(themeState.accentColor),
                ),
                child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'MusicS',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.equalizer_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EqualizerPage()),
              ),
            ),
          ],
        ),

        // Recent songs carousel
        if (audioCtrl.allSongs.length > 3)
          SliverToBoxAdapter(
            child: _RecentCarousel(
              songs: audioCtrl.allSongs.take(8).toList(),
              accentColor: themeState.accentColor,
            ).animate().fadeIn(duration: 400.ms),
          ),

        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'all_songs'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${audioCtrl.allSongs.length} ${'songs'.tr().toLowerCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),

        // Song list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = audioCtrl.allSongs[index];
              final isFav = favorites.contains(song.id);
              final isPlaying = audioCtrl.currentSong?.id == song.id;

              return SongTile(
                song: song,
                isFavorite: isFav,
                isPlaying: isPlaying,
                accentColor: themeState.accentColor,
                onTap: () => audioCtrl.playSong(song),
                onFavoriteTap: () =>
                    ref.read(favoritesProvider.notifier).toggleFavorite(song.id),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 30 * (index.clamp(0, 15))),
                    duration: 300.ms,
                  );
            },
            childCount: audioCtrl.allSongs.length,
          ),
        ),

        // Bottom padding for mini player
        const SliverToBoxAdapter(
          child: SizedBox(height: AppDimensions.miniPlayerHeight + 20),
        ),
      ],
    );
  }
}

/// Recent songs horizontal carousel
class _RecentCarousel extends StatelessWidget {
  final List<SongData> songs;
  final Color accentColor;

  const _RecentCarousel({required this.songs, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            'recent_songs'.tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: AppDimensions.carouselHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return _CarouselCard(
                song: song,
                accentColor: accentColor,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final SongData song;
  final Color accentColor;
  final bool isDark;

  const _CarouselCard({
    required this.song,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final audioCtrl = ProviderScope.containerOf(context).read(audioControllerProvider);
        audioCtrl.playSong(song);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkCard,
                    AppColors.darkCard.withValues(alpha: 0.8),
                  ]
                : [
                    AppColors.lightCard,
                    AppColors.lightCard.withValues(alpha: 0.8),
                  ],
          ),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radiusM),
                  ),
                  color: accentColor.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: QueryArtworkWidget(
                    id: int.tryParse(song.id) ?? 0,
                    type: ArtworkType.AUDIO,
                    artworkBorder: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusM),
                    ),
                    artworkWidth: 160,
                    artworkHeight: 140,
                    artworkFit: BoxFit.cover,
                    nullArtworkWidget: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppDimensions.radiusM),
                        ),
                        gradient: AppColors.accentGradient(accentColor),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.music_note_rounded,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Permission request view
class _PermissionView extends StatelessWidget {
  final AudioController audioCtrl;

  const _PermissionView({required this.audioCtrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'permissions_required'.tr(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'permissions_description'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => audioCtrl.loadSongs(),
              icon: const Icon(Icons.security_rounded),
              label: Text('grant_permissions'.tr()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state view
class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.music_off_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'no_songs'.tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

