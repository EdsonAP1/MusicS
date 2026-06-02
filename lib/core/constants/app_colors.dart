import 'package:flutter/material.dart';

/// Design tokens for MusicS color palette
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════
  // DARK THEME COLORS
  // ═══════════════════════════════════════════
  static const darkBackground = Color(0xFF0A0A0F);
  static const darkSurface = Color(0xFF13132B);
  static const darkCard = Color(0xFF1B1B3A);
  static const darkCardBorder = Color(0xFF2A2A50);
  static const darkNavBar = Color(0xFF0F0F1E);

  // ═══════════════════════════════════════════
  // LIGHT THEME COLORS
  // ═══════════════════════════════════════════
  static const lightBackground = Color(0xFFF6F7FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFF0F1FA);
  static const lightCardBorder = Color(0xFFE2E3F0);
  static const lightNavBar = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════
  // PRIMARY ACCENT COLORS
  // ═══════════════════════════════════════════
  static const primaryPurple = Color(0xFF7C4DFF);
  static const primaryCyan = Color(0xFF00E5FF);
  static const primaryPink = Color(0xFFFF6B9D);
  static const primaryOrange = Color(0xFFFF9E40);
  static const primaryGreen = Color(0xFF00E676);
  static const primaryRed = Color(0xFFFF1744);
  static const primaryBlue = Color(0xFF448AFF);
  static const primaryAmber = Color(0xFFFFD740);

  /// Preset accent colors for user customization
  static const List<Color> accentPresets = [
    primaryPurple,
    primaryCyan,
    primaryPink,
    primaryOrange,
    primaryGreen,
    primaryRed,
    primaryBlue,
    primaryAmber,
    Color(0xFFE040FB), // Purple Accent
    Color(0xFF76FF03), // Lime
    Color(0xFFFF6E40), // Deep Orange Accent
    Color(0xFF40C4FF), // Light Blue Accent
  ];

  // ═══════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════
  static const purpleCyanGradient = LinearGradient(
    colors: [primaryPurple, primaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const pinkOrangeGradient = LinearGradient(
    colors: [primaryPink, primaryOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF16162E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const lightBackgroundGradient = LinearGradient(
    colors: [Color(0xFFF6F7FC), Color(0xFFE8E9F8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ═══════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFB0B0C8);
  static const darkTextTertiary = Color(0xFF6B6B88);

  static const lightTextPrimary = Color(0xFF1A1A2E);
  static const lightTextSecondary = Color(0xFF6B6B88);
  static const lightTextTertiary = Color(0xFF9B9BB0);

  // ═══════════════════════════════════════════
  // GLASSMORPHISM
  // ═══════════════════════════════════════════
  static Color glassWhite = Colors.white.withValues(alpha: 0.08);
  static Color glassBorder = Colors.white.withValues(alpha: 0.15);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.25);
  static Color glassDark = Colors.black.withValues(alpha: 0.4);
  static Color glassDarkBorder = Colors.white.withValues(alpha: 0.08);

  // ═══════════════════════════════════════════
  // QUALITY BADGE COLORS
  // ═══════════════════════════════════════════
  static const qualityLossless = Color(0xFF00E676);
  static const qualityHigh = Color(0xFF448AFF);
  static const qualityStandard = Color(0xFFFFD740);
  static const qualityBasic = Color(0xFFB0B0C8);

  /// Get gradient from accent color
  static LinearGradient accentGradient(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    final lighter = hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
    final shifted = hsl.withHue((hsl.hue + 40) % 360).toColor();
    return LinearGradient(
      colors: [accent, shifted, lighter],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
