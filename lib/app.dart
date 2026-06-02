import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/pages/splash/splash_page.dart';

/// Root MaterialApp with theme, locale, and navigation setup
class MusicSApp extends ConsumerWidget {
  const MusicSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    // Set system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      themeState.isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
            ),
    );

    return MaterialApp(
      title: 'MusicS',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: themeState.themeData,
      themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: themeState.themeData,

      // Localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Home
      home: const SplashPage(),
    );
  }
}
