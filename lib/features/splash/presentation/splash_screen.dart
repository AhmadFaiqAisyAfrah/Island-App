import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../island/presentation/layers/island_base_layer.dart';
import '../../home/presentation/home_screen.dart';
import '../../onboarding/data/onboarding_storage.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../../core/data/shared_preferences_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 1.5s Fixed Duration (Calm Breath)
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final prefs = ref.read(sharedPreferencesProvider);
      final storage = OnboardingStorage(prefs);
      final nextScreen = storage.hasSeenOnboarding ? const HomeScreen() : const OnboardingScreen();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Gentle Fade Transition
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800), // Slow fade
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // EXACT MATCH to HomeScreen Background for seamless visual continuity
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CalmPalette.skyTop,     // 0.0
              CalmPalette.skyMist,    // 0.5
              CalmPalette.deepWater,  // 1.0 (Sea Floor)
            ],
          ),
        ),
        child: Center(
          // Minimal Logo (Image Asset)
          // Responsive Scale: 40% of screen width
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoSize = constraints.maxWidth * 0.45; // 45% Width for confidence
              return Image.asset(
                'assets/icon/island_logo.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              );
            }
          ),
        ),
      ),
    );
  }
}
