import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../island/presentation/island_visual_stack.dart';
import '../../island/presentation/layers/island_base_layer.dart';
import '../../navigation/presentation/island_drawer.dart';
import '../../timer/domain/timer_logic.dart';
import '../../focus_guide/data/quotes_repository.dart';

import '../../../../core/theme/theme_provider.dart';

import 'dart:math' as math; // Add math import

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ... (Code omitted for brevity)
  String _currentQuote = "Ready to focus?";

  @override
  void initState() {
    super.initState();
    _currentQuote = QuotesRepository.getRandomQuote();
  }

  void _updateQuote() {
    setState(() {
      _currentQuote = QuotesRepository.getRandomQuote();
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final themeState = ref.watch(themeProvider); // Returns ThemeState object now
    final isFocusing = timerState.status == TimerStatus.running;
    final isNight = themeState.mode == AppThemeMode.night;

    // Listen for completion
    ref.listen(timerProvider, (previous, next) {
      if (next.status == TimerStatus.completed) {
        showDialog(
          context: context, 
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.skyBottom,
            title: Text('Well done.', style: AppTextStyles.heading),
            content: Text('Take a gently breath.', style: AppTextStyles.body),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(timerProvider.notifier).reset();
                  Navigator.pop(ctx);
                },
                child: Text('Continue', style: TextStyle(color: AppColors.textMain)),
              )
            ],
          )
        );
      }
    });

    return Scaffold(
      drawer: const IslandDrawer(), // 3. The Sidebar
      // The Stack handles the background gradient directly
      body: Stack(
        fit: StackFit.expand, // Force stack to fill the screen
        children: [
          // 1. SKY / OCEAN ATMOSPHERE (Global Gradient)
          Positioned.fill(
             child: AnimatedContainer(
                duration: const Duration(milliseconds: 1200), // Smooth slow transition
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _getBackgroundColors(themeState),
                     // DAY/AUTUMN: Smooth steps. NIGHT: Standard.
                     stops: isNight ? null : [0.0, 0.4, 0.7, 1.0], 
                  )
                )
             )
          ),

          // 2. The Living Island (Midground)
          Positioned.fill(
            child: IslandVisualStack(
              isFocusing: isFocusing,
              themeState: themeState, // Passed down
            ),
          ),
          
          // 2.5 VIGNETTE & NOISE LAYER (Contrast & Anti-Banding for Day Theme)
          // Always present but subtle, ensures White Text is widely readable.
          Positioned.fill(
             child: IgnorePointer( // Allow clicks to pass through
               child: Stack(
                 fit: StackFit.expand,
                 children: [
                   // A. VIGNETTE (Top/Bottom Darkening)
                   Container(
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.topCenter,
                         end: Alignment.bottomCenter,
                         colors: [
                           Colors.black.withOpacity(0.15), // Top Contrast
                           Colors.transparent,
                           Colors.transparent,
                           Colors.black.withOpacity(0.20), // Bottom Contrast
                         ],
                         stops: const [0.0, 0.25, 0.75, 1.0],
                       ),
                     ),
                   ),
                   // B. NOISE (Breaks Color Banding)
                   CustomPaint(painter: _NoisePainter()),
                 ],
               ),
             ),
          ),
          
          // 3. UI Layer (Safe Area)
          SafeArea(
            child: Stack( // Changed Column to Stack to allow absolute positioning of Menu
              children: [
                // HAMBURGER MENU (Top-Left) - Only when idle
                if (!isFocusing)
                  Positioned(
                    top: 16,
                    left: 24,
                    child: Builder( // Builder required to find Scaffold
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu_rounded, size: 28),
                        color: AppColors.textMain.withOpacity(0.6), // Low emphasis
                        tooltip: 'Menu',
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ),

                // Main Layout (Centered Quote & Bottom Controls)
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top: Quote / Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(seconds: 1),
                          child: isFocusing 
                            ? Container(
                                key: ValueKey(_currentQuote),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              /* 
                               * QUOTE / TAGLINE 
                               * Rules: White text, specific opacity, calm typography
                               */
                                child: Text(
                                  _currentQuote,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.subHeading.copyWith(
                                    color: Colors.white.withOpacity(0.95), // Heading: High Opacity
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 0.5,
                                    shadows: AppTextStyles.softShadow, // Subtle reinforcement
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text( 
                                  "Your quiet place.",
                                  style: AppTextStyles.subHeading.copyWith(
                                    color: Colors.white.withOpacity(0.85), // Slightly boosted
                                    letterSpacing: 1.2, 
                                    fontWeight: FontWeight.w400,
                                    shadows: AppTextStyles.softShadow,
                                  ),
                                ),
                              ),
                        ),
                      ),

                      // Center Spacer (Let the Island shine)
                      const Spacer(),

                      // Bottom: Controls
                      Padding(
                        padding: const EdgeInsets.only(bottom: 48.0, left: 24, right: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          // OPTICAL CENTER ALIGNMENT
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Timer Text
                            // Ensure center alignment for font quirks
                            // Timer Text
                            // VISUAL RULE: White, 90% Opacity, No Shadows
                            Text(
                              _formatTime(timerState.remainingSeconds),
                              textAlign: TextAlign.center, 
                              style: AppTextStyles.timer.copyWith(
                                color: Colors.white.withOpacity(0.9), // 90% Opacity
                                letterSpacing: 4.0, // Slightly wider for elegance
                                height: 1.0, // Tighten line height for optical centering
                                shadows: AppTextStyles.softShadow, // Re-added soft shadow for readability
                              ),
                             ),
                            
                            // DURATION SLIDER (Idle Only)
                            if (!isFocusing)
                              Padding(
                                padding: const EdgeInsets.only(top: 24, bottom: 24),
                                child: SizedBox(
                                  width: 280,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 2, 
                                      activeTrackColor: Colors.white.withOpacity(0.5), // Increased visibility
                                      inactiveTrackColor: Colors.white.withOpacity(0.2), // Subtle track
                                      thumbColor: Colors.white,
                                      overlayColor: Colors.white.withOpacity(0.1),
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                    ),
                                    child: Slider(
                                      value: (timerState.initialDuration / 60).clamp(1, 120).toDouble(),
                                      min: 1,
                                      max: 120,
                                      divisions: 119,
                                      onChanged: (val) {
                                        ref.read(timerProvider.notifier).setDuration(val.round());
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Spacing if Slider is hidden
                            // Spacing if Slider is hidden
                            if (isFocusing) const SizedBox(height: 64), // Increased spacing

                            // Primary Action Button
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: isFocusing ? 140 : 200, 
                                  height: 68, // Increased height (+4px)
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFocusing ? Colors.white.withOpacity(0.2) : AppColors.islandGrass,
                                      foregroundColor: Colors.white, // Always White Text
                                      elevation: isFocusing ? 0 : 4,
                                      shadowColor: AppColors.islandCliff.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(34), // Adjusted for height
                                      ),
                                    ),
                                    onPressed: () {
                                      if (isFocusing) {
                                        ref.read(timerProvider.notifier).reset();
                                      } else {
                                        _updateQuote(); 
                                        ref.read(timerProvider.notifier).start();
                                      }
                                    },
                                    child: Text(
                                      isFocusing ? "Stop" : "Begin Focus",
                                      style: AppTextStyles.subHeading.copyWith(
                                        color: Colors.white, // Explicitly White
                                        fontSize: 18, // Increased Size (+1 step)
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for background colors
  List<Color> _getBackgroundColors(ThemeState state) {
    if (state.mode == AppThemeMode.night) {
      return const [
        CalmPalette.nightSkyTop,
        CalmPalette.nightSkyMist,
        CalmPalette.nightDeepWater,
      ];
    }
    
    // Day Modes
    if (state.season == AppSeason.autumn) {
      return const [
        CalmPalette.autumnSky,
        Color(0xFFE2DDD9), // Warm mist intermediate (Beige-Grey)
        CalmPalette.autumnMist,
        CalmPalette.autumnGround, 
      ];
    }

    // Default Day (Original)
    return const [
      CalmPalette.skyTop,
      Color(0xFFE8EEF2),
      CalmPalette.skyMist,
      CalmPalette.deepWater,
    ];
  }
}

// --- PAINTERS ---

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Generate static noise to break gradient banding
    final random = math.Random(42); // Seeded for static consistency
    final paint = Paint();
    final w = size.width;
    final h = size.height;
    
    // Low density noise
    for (int i = 0; i < 2000; i++) {
      paint.color = Colors.white.withOpacity(random.nextDouble() * 0.03); // Tiny white specks
      canvas.drawCircle(Offset(random.nextDouble() * w, random.nextDouble() * h), 1.0, paint);
      
      paint.color = Colors.black.withOpacity(random.nextDouble() * 0.02); // Tiny dark specks
      canvas.drawCircle(Offset(random.nextDouble() * w, random.nextDouble() * h), 1.0, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
