import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/data/database/hive_service.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/providers/locale_provider.dart';

/// Profile page — all personalization settings in one place
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _nameController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: HiveService.userName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final localeState = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
        children: [
          // Header
          Text(
            'profile'.tr(),
            style: Theme.of(context).textTheme.displayMedium,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 4),
          Text(
            'personalization'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Avatar & Name section
          _buildAvatarSection(isDark, themeState),
          const SizedBox(height: 24),

          // ═══ THEME SECTION ═══
          _SectionTitle(title: 'theme'.tr(), icon: Icons.palette_rounded),
          const SizedBox(height: 12),
          // Dark/Light toggle
          _SettingsTile(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: isDark ? 'dark_mode'.tr() : 'light_mode'.tr(),
            trailing: Switch.adaptive(
              value: isDark,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
              activeTrackColor: themeState.accentColor,
            ),
          ),
          const SizedBox(height: 16),

          // Accent Color
          _SectionTitle(title: 'accent_color'.tr(), icon: Icons.color_lens_rounded),
          const SizedBox(height: 12),
          _ColorPicker(
            selectedColor: themeState.accentColor,
            onColorSelected: (color) =>
                ref.read(themeProvider.notifier).setAccentColor(color),
          ),
          const SizedBox(height: 16),

          // Player Color
          _SectionTitle(title: 'player_color'.tr(), icon: Icons.tune_rounded),
          const SizedBox(height: 12),
          _ColorPicker(
            selectedColor: themeState.playerColor,
            onColorSelected: (color) =>
                ref.read(themeProvider.notifier).setPlayerColor(color),
          ),
          const SizedBox(height: 24),

          // ═══ WALLPAPER SECTION ═══
          _SectionTitle(title: 'wallpaper'.tr(), icon: Icons.wallpaper_rounded),
          const SizedBox(height: 12),
          _WallpaperSection(
            currentPath: themeState.wallpaperPath,
            accentColor: themeState.accentColor,
            onPick: () => _pickWallpaper(),
            onClear: () => ref.read(themeProvider.notifier).setWallpaper(null),
          ),
          const SizedBox(height: 24),

          // ═══ VISUALIZER SECTION ═══
          _SectionTitle(title: 'visualizer'.tr(), icon: Icons.equalizer_rounded),
          const SizedBox(height: 12),
          _VisualizerPicker(
            selectedType: themeState.visualizerType,
            accentColor: themeState.accentColor,
            onTypeSelected: (type) =>
                ref.read(themeProvider.notifier).setVisualizerType(type),
          ),
          const SizedBox(height: 16),

          // Progress bar style
          _SectionTitle(title: 'progress_bar_style'.tr(), icon: Icons.linear_scale_rounded),
          const SizedBox(height: 12),
          _ProgressBarPicker(
            selectedType: themeState.progressBarType,
            accentColor: themeState.accentColor,
            onTypeSelected: (type) =>
                ref.read(themeProvider.notifier).setProgressBarType(type),
          ),
          const SizedBox(height: 24),

          // ═══ LANGUAGE SECTION ═══
          _SectionTitle(title: 'language'.tr(), icon: Icons.language_rounded),
          const SizedBox(height: 12),
          _LanguagePicker(
            currentLocale: localeState,
            accentColor: themeState.accentColor,
            onLocaleSelected: (locale) {
              ref.read(localeProvider.notifier).setLocale(locale);
              context.setLocale(locale);
            },
          ),
          const SizedBox(height: 24),

          // ═══ ABOUT SECTION ═══
          _SectionTitle(title: 'about'.tr(), icon: Icons.info_outline_rounded),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.music_note_rounded,
            title: 'MusicS',
            subtitle: '${'version'.tr()} 1.0.0',
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'made_with_love'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(bool isDark, ThemeState themeState) {
    final avatarPath = HiveService.avatarPath;

    return Center(
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient(themeState.accentColor),
                    boxShadow: [
                      BoxShadow(
                        color: themeState.accentColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: avatarPath != null && File(avatarPath).existsSync()
                      ? ClipOval(
                          child: Image.file(File(avatarPath), fit: BoxFit.cover),
                        )
                      : const Icon(Icons.person_rounded, color: Colors.white, size: 44),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeState.accentColor,
                      border: Border.all(
                        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Name
          SizedBox(
            width: 200,
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'user_name'.tr(),
              ),
              onSubmitted: (val) {
                HiveService.userName = val.isEmpty ? 'Music Lover' : val;
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 500.ms,
    );
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 500);
    if (picked != null) {
      HiveService.avatarPath = picked.path;
      setState(() {});
    }
  }

  Future<void> _pickWallpaper() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1920);
    if (picked != null) {
      ref.read(themeProvider.notifier).setWallpaper(picked.path);
    }
  }
}

// ═══════════════════════════════════════════
// REUSABLE WIDGETS
// ═══════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                if (subtitle != null)
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Color picker grid
class _ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorPicker({
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppColors.accentPresets.map((color) {
        final isSelected = color.toARGB32() == selectedColor.toARGB32();
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

/// Wallpaper section
class _WallpaperSection extends StatelessWidget {
  final String? currentPath;
  final Color accentColor;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _WallpaperSection({
    this.currentPath,
    required this.accentColor,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Current wallpaper preview
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: currentPath != null && File(currentPath!).existsSync()
                ? Image.file(File(currentPath!), fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient(accentColor),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 28,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.photo_library_rounded, size: 18),
                label: Text('from_gallery'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (currentPath != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: Text('default_bg'.tr()),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Visualizer type picker
class _VisualizerPicker extends StatelessWidget {
  final int selectedType;
  final Color accentColor;
  final ValueChanged<int> onTypeSelected;

  const _VisualizerPicker({
    required this.selectedType,
    required this.accentColor,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      ('bars'.tr(), Icons.bar_chart_rounded),
      ('waves'.tr(), Icons.waves_rounded),
      ('spectrogram'.tr(), Icons.graphic_eq_rounded),
      ('circular'.tr(), Icons.radio_button_checked_rounded),
    ];

    return Row(
      children: List.generate(types.length, (i) {
        final isSelected = selectedType == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTypeSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < types.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected
                    ? accentColor.withValues(alpha: 0.2)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkCard
                        : AppColors.lightCard),
                border: Border.all(
                  color: isSelected ? accentColor : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    types[i].$2,
                    color: isSelected ? accentColor : null,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    types[i].$1,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? accentColor : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Progress bar style picker
class _ProgressBarPicker extends StatelessWidget {
  final int selectedType;
  final Color accentColor;
  final ValueChanged<int> onTypeSelected;

  const _ProgressBarPicker({
    required this.selectedType,
    required this.accentColor,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      ('linear'.tr(), Icons.linear_scale_rounded),
      ('wave_progress'.tr(), Icons.waves_rounded),
    ];

    return Row(
      children: List.generate(types.length, (i) {
        final isSelected = selectedType == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTypeSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < types.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected
                    ? accentColor.withValues(alpha: 0.2)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkCard
                        : AppColors.lightCard),
                border: Border.all(
                  color: isSelected ? accentColor : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(types[i].$2, color: isSelected ? accentColor : null, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    types[i].$1,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? accentColor : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Language picker
class _LanguagePicker extends StatelessWidget {
  final Locale currentLocale;
  final Color accentColor;
  final ValueChanged<Locale> onLocaleSelected;

  const _LanguagePicker({
    required this.currentLocale,
    required this.accentColor,
    required this.onLocaleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final languages = [
      (const Locale('es'), 'spanish'.tr(), '🇪🇸'),
      (const Locale('en'), 'english'.tr(), '🇺🇸'),
    ];

    return Row(
      children: languages.map((lang) {
        final isSelected = currentLocale.languageCode == lang.$1.languageCode;
        return Expanded(
          child: GestureDetector(
            onTap: () => onLocaleSelected(lang.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: lang.$1.languageCode == 'es' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isSelected
                    ? accentColor.withValues(alpha: 0.2)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkCard
                        : AppColors.lightCard),
                border: Border.all(
                  color: isSelected ? accentColor : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(lang.$3, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    lang.$2,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? accentColor : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
