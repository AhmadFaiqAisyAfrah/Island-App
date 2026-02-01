import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../island/presentation/island_visual_stack.dart';
import '../../island/presentation/layers/island_base_layer.dart';
import '../../navigation/presentation/island_drawer.dart';
import '../../timer/domain/timer_logic.dart';
import '../../focus_guide/data/quotes_repository.dart';

import '../../../../core/theme/theme_provider.dart';

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
    final themeMode = ref.watch(themeProvider);
    final isFocusing = timerState.status == TimerStatus.running;
    final isNight = themeMode == AppThemeMode.night;

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
                    colors: isNight 
                      ? const [ // NIGHT THEME
                          CalmPalette.nightSkyTop,
                          CalmPalette.nightSkyMist,
                          CalmPalette.nightDeepWater,
                        ]
                      : const [ // DAY THEME
                          CalmPalette.skyTop,
                          CalmPalette.skyMist,
                          CalmPalette.deepWater,
                        ],
                  )
                )
             )
          ),

          // 2. The Living Island (Midground)
          Positioned.fill(
            child: IslandVisualStack(
              isFocusing: isFocusing,
              currentTheme: themeMode,
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
                                child: Text(
                                  _currentQuote,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.subHeading.copyWith(
                                    color: AppColors.textMain, 
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic
                                  ),
                                ),
                              )
                            : Padding( // Extra padding to clear the menu
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text( 
                                  "Your quiet place.",
                                  style: AppTextStyles.subHeading.copyWith(color: Colors.white.withOpacity(0.8)),
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
                            Text(
                              _formatTime(timerState.remainingSeconds),
                              textAlign: TextAlign.center, 
                              style: AppTextStyles.timer.copyWith(
                                shadows: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
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
                                      activeTrackColor: AppColors.islandCliff, 
                                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                                      thumbColor: AppColors.islandCliff,
                                      overlayColor: AppColors.islandCliff.withOpacity(0.1),
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
                            if (isFocusing) const SizedBox(height: 48),

                            // Primary Action Button
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: isFocusing ? 140 : 200, 
                                  height: 64,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFocusing ? Colors.white.withOpacity(0.9) : AppColors.islandGrass,
                                      foregroundColor: isFocusing ? AppColors.textMain : Colors.white,
                                      elevation: isFocusing ? 0 : 4,
                                      shadowColor: AppColors.islandCliff.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
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
                                        color: isFocusing ? AppColors.textMain : Colors.white,
                                        fontWeight: FontWeight.w600
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
}
