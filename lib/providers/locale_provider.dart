import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/data/database/hive_service.dart';

/// Manages locale state (Spanish / English)
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('es')) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    state = Locale(HiveService.locale);
  }

  void setLocale(Locale locale) {
    HiveService.locale = locale.languageCode;
    state = locale;
  }

  void toggleLocale() {
    final newLocale = state.languageCode == 'es'
        ? const Locale('en')
        : const Locale('es');
    setLocale(newLocale);
  }

  bool get isSpanish => state.languageCode == 'es';
  bool get isEnglish => state.languageCode == 'en';
}

/// Global locale provider
final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier());
