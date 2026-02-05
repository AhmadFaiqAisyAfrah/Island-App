import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/shared_preferences_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../home/presentation/distant_scenery.dart';
import '../../home/presentation/star_scatter.dart';
import '../../home/presentation/home_screen.dart';
import '../../island/presentation/island_visual_stack.dart';
import '../../island/presentation/layers/island_base_layer.dart';
import '../../onboarding/data/onboarding_storage.dart';
import '../../timer/domain/timer_logic.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _pulseController;
  int _pageIndex = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: "You've arrived.",
      subtitle: 'Meet your calm island.',
      ctaLabel: null,
      visualType: _OnboardingVisualType.arrival,
      gradient: [
        Color(0xFFF3ECE4),
        Color(0xFFE6EEF1),
        Color(0xFFD4E0E6),
      ],
    ),
    _OnboardingSlide(
      title: 'Name your focus.',
      subtitle: 'Small rituals make a big difference.',
      ctaLabel: null,
      visualType: _OnboardingVisualType.intention,
      gradient: [
        Color(0xFFF2E6D8),
        Color(0xFFE2EBEE),
        Color(0xFFCBD9DF),
      ],
    ),
    _OnboardingSlide(
      title: 'Begin.',
      subtitle: 'Your calm space is ready.',
      ctaLabel: 'Enter Island',
      visualType: _OnboardingVisualType.invitation,
      gradient: [
        CalmPalette.skyTop,
        Color(0xFFE8EEF2),
        CalmPalette.skyMist,
        CalmPalette.deepWater,
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final storage = OnboardingStorage(prefs);
    await storage.setComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(_fadeRoute(const HomeScreen()));
  }

  PageRouteBuilder<void> _fadeRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_pageIndex];
    final bool showIsland = slide.visualType == _OnboardingVisualType.invitation;
    final ThemeState islandTheme = const ThemeState(mode: AppThemeMode.night);
    final bool isNight = showIsland;
    final bgColors = showIsland ? _getBackgroundColors(islandTheme) : slide.gradient;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: bgColors,
              ),
            ),
          ),
          if (showIsland && isNight)
            const Positioned.fill(
              child: StarScatter(count: 60),
            ),
          if (showIsland)
            Positioned.fill(
              child: DistantScenery(themeState: islandTheme),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final scale = Tween<double>(begin: 0.96, end: 1.0).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: scale, child: child),
                  );
                },
                child: showIsland
                    ? _IslandInvitation(
                        key: const ValueKey('island'),
                        themeState: islandTheme,
                        pulse: _pulseController,
                      )
                    : _OnboardingVisual(
                        key: ValueKey(slide.visualType),
                        type: slide.visualType,
                      ),
              ),
            ),
          ),
          const Positioned.fill(child: _NoiseLayer()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: isNight
                              ? Colors.white.withOpacity(0.6)
                              : AppColors.textMain.withOpacity(0.65),
                        ),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) => setState(() => _pageIndex = index),
                    itemBuilder: (context, index) {
                      final page = _slides[index];
                      return _OnboardingPage(
                        slide: page,
                        showCta: index == _slides.length - 1,
                        onCtaTap: _completeOnboarding,
                        currentIndex: _pageIndex,
                        total: _slides.length,
                        isNight: isNight,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getBackgroundColors(ThemeState state) {
    final bool isNight = state.mode == AppThemeMode.night;
    final environment = state.environment;
    final season = state.season;

    switch (environment) {
      case AppEnvironment.mountain:
        return isNight
            ? [const Color(0xFF232526), const Color(0xFF414345)]
            : [const Color(0xFFE6DADA), const Color(0xFF274046)];

      case AppEnvironment.beach:
        return isNight
            ? [const Color(0xFF0F2027), const Color(0xFF203A43)]
            : [const Color(0xFF89F7FE), const Color(0xFF66A6FF)];

      case AppEnvironment.forest:
        return isNight
            ? [const Color(0xFF093028), const Color(0xFF237A57)]
            : [const Color(0xFFD3CCE3), const Color(0xFFE9E4F0)];

      case AppEnvironment.defaultSky:
      default:
        if (isNight) {
          return [CalmPalette.winterNightTop, CalmPalette.winterNightBot];
        }

        if (season == AppSeason.winter) {
          return [CalmPalette.winterSky, CalmPalette.winterDayMist];
        }

        if (season == AppSeason.autumn) {
          return const [
            CalmPalette.autumnSky,
            Color(0xFFE2DDD9),
            CalmPalette.autumnMist,
            CalmPalette.autumnGround,
          ];
        }

        return const [
          CalmPalette.skyTop,
          Color(0xFFE8EEF2),
          CalmPalette.skyMist,
          CalmPalette.deepWater,
        ];
    }
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingSlide slide;
  final bool showCta;
  final VoidCallback onCtaTap;
  final int currentIndex;
  final int total;
  final bool isNight;

  const _OnboardingPage({
    required this.slide,
    required this.showCta,
    required this.onCtaTap,
    required this.currentIndex,
    required this.total,
    required this.isNight,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading.copyWith(
                fontSize: 30,
                height: 1.1,
                color: isNight ? Colors.white.withOpacity(0.95) : AppColors.textMain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              slide.subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: isNight
                    ? Colors.white.withOpacity(0.82)
                    : AppColors.textMain.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _ProgressDots(
              total: total,
              currentIndex: currentIndex,
              isNight: isNight,
            ),
            if (showCta) ...[
              const SizedBox(height: 18),
              _PrimaryButton(
                label: slide.ctaLabel ?? 'Enter Island',
                onTap: onCtaTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.islandGrass,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Text(
          label,
          style: AppTextStyles.subHeading.copyWith(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int total;
  final int currentIndex;
  final bool isNight;

  const _ProgressDots({
    required this.total,
    required this.currentIndex,
    required this.isNight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? (isNight
                    ? Colors.white.withOpacity(0.9)
                    : AppColors.islandGrass.withOpacity(0.9))
                : Colors.white.withOpacity(isNight ? 0.4 : 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _NoiseLayer extends StatelessWidget {
  const _NoiseLayer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NoisePainter(),
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();
    final w = size.width;
    final h = size.height;

    for (int i = 0; i < 1600; i++) {
      paint.color = Colors.white.withOpacity(random.nextDouble() * 0.03);
      canvas.drawCircle(
        Offset(random.nextDouble() * w, random.nextDouble() * h),
        1.0,
        paint,
      );
      paint.color = Colors.black.withOpacity(random.nextDouble() * 0.02);
      canvas.drawCircle(
        Offset(random.nextDouble() * w, random.nextDouble() * h),
        1.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) => false;
}

enum _OnboardingVisualType { arrival, intention, invitation }

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final _OnboardingVisualType visualType;
  final List<Color> gradient;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.visualType,
    required this.gradient,
  });
}

class _OnboardingVisual extends StatelessWidget {
  final _OnboardingVisualType type;

  const _OnboardingVisual({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.15),
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (type == _OnboardingVisualType.arrival) const _ArrivalVisual(),
            if (type == _OnboardingVisualType.intention) const _IntentionVisual(),
          ],
        ),
      ),
    );
  }
}

class _ArrivalVisual extends StatelessWidget {
  const _ArrivalVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _SoftOrb(color: const Color(0xFFE4D6C8), size: 260),
        _SoftOrb(color: const Color(0xFFD6E3E8), size: 210),
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.55),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}

class _IntentionVisual extends StatelessWidget {
  const _IntentionVisual();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _SoftOrb(color: const Color(0xFFE8DCCB), size: 260),
        _SoftOrb(color: const Color(0xFFDDE7EA), size: 210),
        Container(
          width: 220,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.islandGrass.withOpacity(0.2),
                ),
                alignment: Alignment.center,
                child: const Text('•', style: TextStyle(fontSize: 24, color: AppColors.textMain)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.textMain.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.textMain.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 38,
          right: 48,
          child: Container(
            width: 70,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

class _SoftOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _SoftOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.55), color.withOpacity(0.0)],
        ),
      ),
    );
  }
}

class _IslandInvitation extends StatelessWidget {
  final ThemeState themeState;
  final Animation<double> pulse;

  const _IslandInvitation({super.key, required this.themeState, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return AnimatedBuilder(
          animation: pulse,
          builder: (context, child) {
            final curved = Curves.easeInOut.transform(pulse.value);
            final t = curved * math.pi * 2;
            final bob = math.sin(t) * 2.0;
            final breathe = 1.0075 + math.sin(t) * 0.0075;
            final glowOpacity = 0.22 + (math.sin(t) + 1) * 0.06;

            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: h * 0.26,
                  child: Opacity(
                    opacity: glowOpacity,
                    child: Container(
                      width: w * 0.7,
                      height: w * 0.45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(w),
                        gradient: RadialGradient(
                          colors: [
                            AppColors.skyBottom.withOpacity(0.6),
                            AppColors.skyBottom.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, bob),
                  child: Transform.scale(
                    scale: breathe,
                    child: child,
                  ),
                ),
              ],
            );
          },
          child: IslandVisualStack(
            isFocusing: false,
            themeState: themeState,
            currentSeconds: TimerNotifier.defaultDuration,
            totalSeconds: 7200,
            onDurationChanged: null,
            showSlider: false,
            enableCharacterIdleMotion: true,
          ),
        );
      },
    );
  }
}
