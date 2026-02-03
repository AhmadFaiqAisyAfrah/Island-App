import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../island/presentation/island_visual_stack.dart';
import '../../island/presentation/layers/island_base_layer.dart';
import '../../navigation/presentation/island_drawer.dart';
import '../../timer/domain/timer_logic.dart';
import '../../focus_guide/data/quotes_repository.dart';

import '../../../../core/theme/theme_provider.dart';
import 'distant_scenery.dart';

import 'dart:math' as math;
import '../../shop/data/currency_provider.dart';
import '../../shop/presentation/shop_screen.dart';
import '../../music/presentation/music_button.dart';
import '../../music/data/audio_service.dart'; // Import Provider

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
    final themeState = ref.watch(themeProvider);
    final coinBalance = ref.watch(currencyProvider); // Watch coins
    final isFocusing = timerState.status == TimerStatus.running;
    final isNight = themeState.mode == AppThemeMode.night;
    final bgColors = _getBackgroundColors(themeState);

    // Listen for completion
    ref.listen(timerProvider, (previous, next) {
      if (next.status == TimerStatus.completed) {
        // Calculate Reward (1 Coin per minute)
        final int minutesFocused = next.initialDuration ~/ 60;
        final int reward = minutesFocused > 0 ? minutesFocused : 1;
        
        // Award Coins
        ref.read(currencyProvider.notifier).addCoins(reward);

        // Music continues independent of timer
        // ref.read(audioServiceProvider.notifier).stopPlayback();

        showDialog(
          context: context, 
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.skyBottom,
            title: Column(
              children: [
                const Text("🧘", style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text('Well done.', style: AppTextStyles.heading),
              ],
            ),
            content: Text(
              'You focused for $minutesFocused minutes\nand earned $reward coins!',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(timerProvider.notifier).reset();
                    Navigator.pop(ctx);
                  },
                  child: Text('Collect', style: TextStyle(color: AppColors.islandCliff, fontWeight: FontWeight.bold)),
                ),
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
                    colors: bgColors,
                     // DAY/AUTUMN: Smooth steps. NIGHT: Standard.
                     stops: isNight ? null : (bgColors.length == 4 ? [0.0, 0.4, 0.7, 1.0] : [0.0, 1.0]), 
                  )
                )
             )
          ),

          // 1.5 DISTANT SCENERY (Environment Specific)
          Positioned.fill(
             child: DistantScenery(themeState: themeState),
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



                // DAY/NIGHT TOGGLE (Top-Right) - Only when idle
                if (!isFocusing)
                  Positioned(
                    top: 16,
                    right: 24,
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                        child: Icon(
                          isNight ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          key: ValueKey(isNight),
                          size: 26,
                        ),
                      ),
                      color: AppColors.textMain.withOpacity(0.6), 
                      tooltip: isNight ? 'Switch over to Day' : 'Switch over to Night',
                      onPressed: () => ref.read(themeProvider.notifier).toggleMode(),
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
                            : Column(
                                children: [
                                  Padding(
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
                                  const SizedBox(height: 12),
                                  // CENTERED COIN BALANCE (Secondary)
                                  if (!isFocusing)
                                    GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen())),
                                      child: Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                         decoration: BoxDecoration(
                                           color: const Color(0xFFF2F2F2).withOpacity(0.9), // Soft Off-White, High Opacity
                                           borderRadius: BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              )
                                            ],
                                         ),
                                         child: Row(
                                           mainAxisSize: MainAxisSize.min,
                                           children: [
                                             const Text("🪙", style: TextStyle(
                                               fontSize: 16, 
                                             )),
                                             const SizedBox(width: 8),
                                             Text(
                                               "$coinBalance",
                                               style: AppTextStyles.body.copyWith(
                                                 color: AppColors.textMain, // Dark Slate for readability
                                                 fontSize: 15,
                                                 fontWeight: FontWeight.w600,
                                                 height: 1.0,
                                               ),
                                             ),
                                           ],
                                         ),
                                      ),
                                    ),
                                ],
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
                                color: Colors.white, // Pure white for primary focus
                                fontWeight: FontWeight.w300, // Slightly bolder than w200
                                letterSpacing: 4.0, 
                                height: 1.0, 
                                shadows: AppTextStyles.softShadow,
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
                                      trackHeight: 4, // Slightly thicker for visibility
                                      activeTrackColor: Colors.white.withOpacity(0.8), // Higher contrast
                                      inactiveTrackColor: Colors.white.withOpacity(0.3), // More visible track
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
                            // Primary Action Button & Music Toggle
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: SizedBox(
                                height: 80, // Sufficient height for the button
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    // Focus Button (Always Centered)
                                    Center(
                                      child: _AnimatedFocusButton(
                                        isFocusing: isFocusing,
                                        themeState: themeState,
                                        onTap: () {
                                          if (isFocusing) {
                                            ref.read(timerProvider.notifier).reset();
                                            // AUDIO FROZEN FOR MVP
                                            // ref.read(audioServiceProvider).disable();
                                          } else {
                                            _updateQuote(); 
                                            ref.read(timerProvider.notifier).start();
                                            // AUDIO FROZEN FOR MVP
                                            // if (ref.read(audioEnabledProvider)) {
                                            //    ref.read(audioServiceProvider).enable();
                                            // }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
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
          ),
        ],
      ),
    );
  }

  // Helper for background colors
  List<Color> _getBackgroundColors(ThemeState state) {
    final bool isNight = state.mode == AppThemeMode.night;
    final environment = state.environment;
    final season = state.season;

    // 1. SPECIFIC ENVIRONMENTS
    switch (environment) {
      case AppEnvironment.mountain:
        // Cold, majestic purple-grey
        return isNight 
          ? [const Color(0xFF232526), const Color(0xFF414345)] 
          : [const Color(0xFFE6DADA), const Color(0xFF274046)]; 
      
      case AppEnvironment.beach:
        // Warm cyan/teal
        return isNight 
          ? [const Color(0xFF0F2027), const Color(0xFF203A43)] 
          : [const Color(0xFF89F7FE), const Color(0xFF66A6FF)]; 

      case AppEnvironment.forest:
        // Deep greens and mists
        return isNight 
          ? [const Color(0xFF093028), const Color(0xFF237A57)] 
          : [const Color(0xFFD3CCE3), const Color(0xFFE9E4F0)]; 

      case AppEnvironment.space:
        // Always deep dark
        return [const Color(0xFF000000), const Color(0xFF434343)]; 

      case AppEnvironment.defaultSky:
      default:
        // 2. DEFAULT (SEASONAL SKY)
        
        // Unified Night (Premium)
        if (isNight) {
           return [CalmPalette.winterNightTop, CalmPalette.winterNightBot];
        }

        // Winter Day
        if (season == AppSeason.winter) {
          return [CalmPalette.winterSky, CalmPalette.winterDayMist];
        }
        
        // Autumn Day
        if (season == AppSeason.autumn) {
           return const [
             CalmPalette.autumnSky,
             Color(0xFFE2DDD9), 
             CalmPalette.autumnMist,
             CalmPalette.autumnGround, 
           ];
        }

        // Normal / Sakura Day
        return const [
          CalmPalette.skyTop,
          Color(0xFFE8EEF2),
          CalmPalette.skyMist,
          CalmPalette.deepWater,
        ];
    }
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

// --- WIDGETS ---

class _AnimatedFocusButton extends StatefulWidget {
  final bool isFocusing;
  final ThemeState themeState;
  final VoidCallback onTap;

  const _AnimatedFocusButton({
    required this.isFocusing,
    required this.themeState,
    required this.onTap,
  });

  @override
  State<_AnimatedFocusButton> createState() => _AnimatedFocusButtonState();
}

class _AnimatedFocusButtonState extends State<_AnimatedFocusButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, 
        duration: const Duration(milliseconds: 150),
        reverseDuration: const Duration(milliseconds: 150)
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    if (mounted) _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  Color _getButtonColor() {
    if (widget.isFocusing) {
       return Colors.white.withOpacity(0.2);
    }
    
    final isNight = widget.themeState.mode == AppThemeMode.night;
    final season = widget.themeState.season;
    final env = widget.themeState.environment;

    // 1. Space Environment (Override everything)
    if (env == AppEnvironment.space) {
       // Dark charcoal green
       return const Color(0xFF2F4F4F); 
    }

    // 2. Night Mode (General)
    if (isNight) {
       // Warm Olive Green
       return const Color(0xFF556B2F); 
    }

    // 3. Day Mode (Seasonal)
    switch (season) {
      case AppSeason.sakura:
        // Desaturated Sage w/ Blush
        return const Color(0xFF8FA998); 
      case AppSeason.autumn:
        // Warm Moss
        return const Color(0xFF708238); 
      case AppSeason.winter:
        // Cool Grey-Green
        return const Color(0xFF78909C); 
      case AppSeason.normal:
      default:
        // Standard Soft Sage
        return AppColors.islandGrass;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
           return Transform.scale(
             scale: _scaleAnim.value,
             child: child,
           );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500), // Slow color transition
          width: widget.isFocusing ? 140 : 200,
          height: 68,
            decoration: BoxDecoration(
              color: _getButtonColor(),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0), // Added local border contrast
              boxShadow: widget.isFocusing ? [] : [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.25), // Slightly stronger shadow
                   blurRadius: 16, // Softer blur
                   offset: const Offset(0, 6), // Slightly lower
                 )
              ],
            ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              widget.isFocusing ? "Stop" : "Begin Focus",
              key: ValueKey(widget.isFocusing),
              style: AppTextStyles.subHeading.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
