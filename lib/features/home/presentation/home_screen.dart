import 'dart:async';
import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../island/presentation/island_visual_stack.dart';
import '../../island/presentation/layers/island_base_layer.dart';
import '../../navigation/presentation/island_drawer.dart';
import '../../timer/domain/timer_logic.dart';
import '../../focus_guide/data/quotes_repository.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../core/data/feature_discovery_provider.dart';
import '../../../../core/data/shared_preferences_provider.dart';
import '../../../../core/widgets/glass_hint.dart';
import 'distant_scenery.dart';
import 'star_scatter.dart';

import 'dart:math' as math;
import '../../shop/presentation/shop_screen.dart';
import '../../../../core/widgets/island_coin_icon.dart';
import '../../../../services/point_service.dart';
import '../../archipelago/data/archipelago_provider.dart';
import '../../tags/presentation/tags_provider.dart';
import '../../music/presentation/music_icon_button.dart';
import '../../../services/music_service.dart';
import '../../tags/presentation/tag_selector.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  // ... (Code omitted for brevity)
  String _currentQuote = "Your quiet place."; 
  Timer? _quoteRotationTimer;
  DateTime? _pausedAt;
  bool _showFocusHint = false;
  String _selectedMusic = 'None'; // Track selected music: None, Rainy Vibes, Forest Vibes
  
  // Theme selection state
  String _selectedTheme = 'Original Island';
  TabController? _tabController;
  bool _collapseAllByDefault = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);
    // Initial Headline
    _currentQuote = QuotesRepository.getDashboardHeadline();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final discovery = ref.read(featureDiscoveryProvider);
      if (!discovery.hasSeenFocusHint) {
        setState(() => _showFocusHint = true);
        ref.read(featureDiscoveryProvider.notifier).markFocusHintSeen();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
      _quoteRotationTimer?.cancel(); // Pause rotation
    } else if (state == AppLifecycleState.resumed) {
      _resumeCopyRotation();
    }
  }

  void _resumeCopyRotation() {
    final now = DateTime.now();
    // Rotate Header if idle > 30 mins
    if (_pausedAt != null && now.difference(_pausedAt!).inMinutes > 30) {
      final timerState = ref.read(timerProvider);
      if (timerState.status != TimerStatus.running) {
        setState(() => _currentQuote = QuotesRepository.getDashboardHeadline());
      }
    }
    
    // Resume Timer if focusing
    final timerState = ref.read(timerProvider);
    if (timerState.status == TimerStatus.running) {
      _startFocusRotation();
    }
  }

  void _startFocusRotation() {
    _quoteRotationTimer?.cancel();
    // Rotate every 6 minutes (360s)
    _quoteRotationTimer = Timer.periodic(const Duration(minutes: 6), (_) {
      final timerState = ref.read(timerProvider);
      if (mounted && timerState.status == TimerStatus.running) {
         setState(() => _currentQuote = QuotesRepository.getFocusQuote());
      }
    });
  }

  void _stopFocusRotation() {
    _quoteRotationTimer?.cancel();
    _quoteRotationTimer = null;
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
    final prefs = ref.watch(sharedPreferencesProvider);
    final pointService = PointService(prefs);
    final coinBalance = pointService.getCurrentPoints(); // Unified coin source
    final isFocusing = timerState.status == TimerStatus.running;
    final isNight = themeState.mode == AppThemeMode.night;
    final bgColors = _getBackgroundColors(themeState);

    // Listen for completion & state changes
    ref.listen(timerProvider, (previous, next) {
      // START FOCUS
       if (next.status == TimerStatus.running && (previous?.status != TimerStatus.running)) {
         setState(() {
           _currentQuote = QuotesRepository.getFocusQuote();
           _startFocusRotation();
           _showFocusHint = false;
         });
      }
      // STOP/PAUSE FOCUS
       else if (previous?.status == TimerStatus.running && next.status != TimerStatus.running) {
          _stopFocusRotation();
          // Stop music when focus stops
          MusicService.instance.stop();
          if (next.status == TimerStatus.idle) {
             setState(() => _currentQuote = QuotesRepository.getDashboardHeadline());
          }
       }

      if (next.status == TimerStatus.completed) {
        // Calculate Reward (1 Coin per minute)
        final int minutesFocused = next.initialDuration ~/ 60;
        final int reward = minutesFocused > 0 ? minutesFocused : 1;
        
        // Award Coins using PointService (unified source)
        pointService.addPoints(reward);

        // Archipelago: Save Daily Progress
        final selectedTag = ref.read(selectedTagProvider);
        ref.read(archipelagoProvider.notifier).addSession(
          durationSeconds: next.initialDuration, 
          tagLabel: selectedTag.label, 
          tagEmoji: selectedTag.emoji
        );

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

          // 1.25 STAR SCATTER (Global Night Layer)
          // Always present at night, behind scenery.
          if (isNight)
             const Positioned.fill(
               child: StarScatter(count: 60), 
             ),

          // 1.5 DISTANT SCENERY (Environment Specific)
          Positioned.fill(
             child: DistantScenery(themeState: themeState),
          ),

          // 2. The Living Island (Midground)
          Positioned.fill(
            child: IslandVisualStack(
              isFocusing: isFocusing,
              themeState: themeState,
              currentSeconds: isFocusing ? timerState.remainingSeconds : timerState.initialDuration,
              totalSeconds: isFocusing ? timerState.initialDuration : 7200, 
              onDurationChanged: (val) {
                 if (!isFocusing) {
                    ref.read(timerProvider.notifier).setDuration(val);
                 }
              },
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
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter: dart_ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Container(
                                    key: ValueKey(_currentQuote),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // Slightly more breathing room
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(isNight ? 0.08 : 0.4), // Lower than buttons (0.15/0.65)
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(isNight ? 0.1 : 0.3),
                                        width: 1.0,
                                      ),
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
                              ),
                            ),
                            ) // Close ClipRRect
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Text( 
                                      _currentQuote, // Use dynamic quote even for headline
                                      key: ValueKey(_currentQuote),
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
                                           color: isNight 
                                              ? Colors.white.withOpacity(0.15) 
                                              : Colors.white.withOpacity(0.65), // Unified Glass
                                           borderRadius: BorderRadius.circular(30),
                                           border: Border.all(
                                             color: Colors.white.withOpacity(0.5), 
                                             width: 1.0
                                           ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              )
                                            ],
                                         ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const IslandCoinIcon(size: 22),
                                              const SizedBox(width: 6),
                                               Text(
                                                '$coinBalance',
                                                style: AppTextStyles.body.copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isNight ? Colors.white : AppColors.textMain,
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
                        padding: const EdgeInsets.only(bottom: 12.0, left: 24, right: 24), // Reduced bottom padding further to move controls lower
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                            // OPTICAL CENTER ALIGNMENT
                          crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             // CONTROL ROW: Session Tag + Music (horizontal layout)
                             if (!isFocusing)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Session Tag (left)
                                    TagSelector(isFocusing: isFocusing),
                                    const SizedBox(width: 12),
                                    // Music Icon Button (right)
                                    MusicIconButton(
                                     initialValue: _selectedMusic,
                                     onMusicSelected: (music) {
                                       setState(() {
                                         _selectedMusic = music;
                                       });
                                     },
                                   ),
                                 ],
                               )
                             else
                               // During focus: show TagSelector in disabled state
                               TagSelector(isFocusing: isFocusing),
                             
                             if (!isFocusing && _showFocusHint) ...[
                              const SizedBox(height: 16),
                              GlassHint(
                                text: 'Set your time. Let the island breathe with you.',
                                isNight: isNight,
                                onDismiss: () => setState(() => _showFocusHint = false),
                              ),
                              const SizedBox(height: 20),
                            ] else
                              const SizedBox(height: 32),

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
                            
                            // DURATION SLIDER MOVED TO ISLAND RING
                            
                            const SizedBox(height: 56), // Adjusted spacing to move controls down (~16px lower)

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
                                            // STOP FOCUS
                                            ref.read(timerProvider.notifier).reset();
                                            // Stop music when focus ends
                                            MusicService.instance.stop();
                                          } else {
                                            // START FOCUS
                                            ref.read(timerProvider.notifier).start();
                                            // Start music based on selection
                                            MusicService.instance.stop(); // Reset first
                                            switch (_selectedMusic) {
                                              case 'Rainy Vibes':
                                                MusicService.instance.switchTrack(MusicTrack.rainy);
                                                MusicService.instance.playCurrentTrack();
                                                break;
                                               case 'Forest Vibes':
                                                 MusicService.instance.switchTrack(MusicTrack.forest);
                                                 MusicService.instance.playCurrentTrack();
                                                 break;
                                               case 'Night Vibes':
                                                 MusicService.instance.switchTrack(MusicTrack.night);
                                                 MusicService.instance.playCurrentTrack();
                                                 break;
                                               case 'Snow Vibes':
                                                 MusicService.instance.switchTrack(MusicTrack.snow);
                                                 MusicService.instance.playCurrentTrack();
                                                 break;
                                               case 'Ocean Vibes':
                                                 MusicService.instance.switchTrack(MusicTrack.ocean);
                                                 MusicService.instance.playCurrentTrack();
                                                 break;
                                               case 'None':
                                               default:
                                                 // No music selected, do nothing
                                                 break;
                                             }
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
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  Color _getButtonBaseColor() {
    if (widget.isFocusing) {
       return Colors.white.withOpacity(0.15); // Translucent when active
    }
    
    final isNight = widget.themeState.mode == AppThemeMode.night;
    // Unified Glass Material (White-based)
    if (isNight) {
       return Colors.white.withOpacity(0.12); // Slightly more visible for contrast
    } else {
       return Colors.white.withOpacity(0.25); // Airy, light glass
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... logic ...
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: dart_ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500), 
              width: widget.isFocusing ? 140 : 200,
              height: 68,
                decoration: BoxDecoration(
                  color: _getButtonBaseColor(),
                  borderRadius: BorderRadius.circular(34), // Required for border alignment
                  // Shared Material Features:
                  border: Border.all(
                    color: Colors.white.withOpacity(widget.isFocusing ? 0.2 : 0.4), 
                    width: 1.0
                  ), 
                  boxShadow: widget.isFocusing ? [] : [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.03), // Extremely subtle shadow
                       blurRadius: 10, 
                       offset: const Offset(0, 4), 
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
      ),
    ),
  );
  }
}
