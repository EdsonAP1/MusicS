import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Convenience extensions on BuildContext
extension ContextExtensions on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDark => theme.brightness == Brightness.dark;

  // Size shortcuts
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get bottomInset => MediaQuery.viewInsetsOf(this).bottom;

  // Navigation
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
    MaterialPageRoute(builder: (_) => page),
  );
  Future<T?> pushReplacement<T>(Widget page) => Navigator.of(this).pushReplacement(
    MaterialPageRoute(builder: (_) => page),
  );

  // Snackbar
  void showSnack(String message) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Localization shortcut
  String tr(String key) => key.tr();
}
