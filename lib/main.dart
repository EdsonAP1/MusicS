import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_application_1/data/database/hive_service.dart';
import 'package:flutter_application_1/app.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Hive database
  await HiveService.init();

  // Initialize background audio service
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.musics.player.channel.audio',
    androidNotificationChannelName: 'Music Playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/launcher_icon',
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/l10n',
      fallbackLocale: const Locale('es'),
      startLocale: Locale(HiveService.locale),
      child: const ProviderScope(child: MusicSApp()),
    ),
  );
}
