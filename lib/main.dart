import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/archipelago/data/archipelago_repository.dart';
import 'features/archipelago/data/archipelago_provider.dart';
import 'core/data/shared_preferences_provider.dart';
import 'services/music_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final prefs = await SharedPreferences.getInstance();
  final repository = ArchipelagoRepository(prefs);
  
  // Initialize MusicService (singleton, non-blocking)
  // Audio will be preloaded and ready for playback
  MusicService().init();

  runApp(
    ProviderScope(
      overrides: [
        archipelagoRepoProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const IslandApp(),
    ),
  );
}

class IslandApp extends StatelessWidget {
  const IslandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Island',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.pastelTheme,
      // Enforce the pastel theme for the MVP visual consistency
      themeMode: ThemeMode.light, 
      home: const SplashScreen(),
    );
  }
}
