import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/data/database/hive_service.dart';

/// Theme state
class ThemeState {
  final bool isDarkMode;
  final Color accentColor;
  final Color playerColor;
  final String? wallpaperPath;
  final int visualizerType; // 0=bars, 1=waves, 2=spectrogram, 3=circular
  final int progressBarType; // 0=linear, 1=wave

  const ThemeState({
    this.isDarkMode = true,
    this.accentColor = AppColors.primaryPurple,
    this.playerColor = AppColors.primaryPurple,
    this.wallpaperPath,
    this.visualizerType = 0,
    this.progressBarType = 0,
  });

  ThemeState copyWith({
    bool? isDarkMode,
    Color? accentColor,
    Color? playerColor,
    String? wallpaperPath,
    bool clearWallpaper = false,
    int? visualizerType,
    int? progressBarType,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      accentColor: accentColor ?? this.accentColor,
      playerColor: playerColor ?? this.playerColor,
      wallpaperPath: clearWallpaper ? null : (wallpaperPath ?? this.wallpaperPath),
      visualizerType: visualizerType ?? this.visualizerType,
      progressBarType: progressBarType ?? this.progressBarType,
    );
  }

  /// Get the current ThemeData
  ThemeData get themeData => isDarkMode
      ? AppTheme.darkTheme(accentColor: accentColor)
      : AppTheme.lightTheme(accentColor: accentColor);
}

/// Theme state notifier — manages dark/light, colors, wallpaper, visualizer
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    state = ThemeState(
      isDarkMode: HiveService.isDarkMode,
      accentColor: HiveService.accentColor,
      playerColor: HiveService.playerColor,
      wallpaperPath: HiveService.wallpaperPath,
      visualizerType: HiveService.visualizerType,
      progressBarType: HiveService.progressBarType,
    );
  }

  void toggleTheme() {
    final newMode = !state.isDarkMode;
    HiveService.isDarkMode = newMode;
    state = state.copyWith(isDarkMode: newMode);
  }

  void setAccentColor(Color color) {
    HiveService.accentColorValue = color.toARGB32();
    state = state.copyWith(accentColor: color);
  }

  void setPlayerColor(Color color) {
    HiveService.playerColorValue = color.toARGB32();
    state = state.copyWith(playerColor: color);
  }

  void setWallpaper(String? path) {
    HiveService.wallpaperPath = path;
    if (path == null) {
      state = state.copyWith(clearWallpaper: true);
    } else {
      state = state.copyWith(wallpaperPath: path);
    }
  }

  void setVisualizerType(int type) {
    HiveService.visualizerType = type;
    state = state.copyWith(visualizerType: type);
  }

  void setProgressBarType(int type) {
    HiveService.progressBarType = type;
    state = state.copyWith(progressBarType: type);
  }
}

/// Global theme provider
final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) => ThemeNotifier());
