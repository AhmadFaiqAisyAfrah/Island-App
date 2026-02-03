import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: IslandApp(),
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
