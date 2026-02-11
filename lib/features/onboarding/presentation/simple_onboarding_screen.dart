import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimpleOnboardingScreen extends StatefulWidget {
  const SimpleOnboardingScreen({super.key});

  @override
  State<SimpleOnboardingScreen> createState() => _SimpleOnboardingScreenState();
}

class _SimpleOnboardingScreenState extends State<SimpleOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize breathing animation controller
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 4500), // 4.5 seconds per cycle
      vsync: this,
    );
    
    // Create breathing animation (0.98 → 1.0 → 0.98)
    _breathingAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // Start animation automatically on screen load
    _breathingController.repeat(reverse: true);
    
    // Show button after 500-700ms delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isNight = themeState.mode == AppThemeMode.night;
    
    return Scaffold(
      body: Container(
        // Light, breathable gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isNight
                ? [
                    const Color(0xFF1a1a2e), // Dark blue-gray
                    const Color(0xFF2d2d44), // Slightly darker
                  ]
                : [
                    const Color(0xFFF8F9FA), // Very light gray
                    const Color(0xFFE9ECEF), // Soft gray
                  ],
          ),
        ),
        // Subtle grain/noise texture
        child: CustomPaint(
          painter: _SubtleGrainPainter(),
          child: SafeArea(
            child: Stack(
              children: [
                // Secondary action - Skip button in top-right
                Positioned(
                  top: 20,
                  right: 20,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigation logic placeholder
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFF64748B), // Low visual priority
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                
                // Center content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Central visual element with breathing animation
                      AnimatedBuilder(
                        animation: _breathingAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _breathingAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isNight
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                                boxShadow: [
                                  BoxShadow(
                                    color: isNight
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    
                      const SizedBox(height: 60),
                    
                      // Text content - exactly as specified
                      const Text(
                        'Life feels loud lately.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28, // Larger text
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF2C3E50), // Dark color for both modes
                          height: 1.4,
                        ),
                      ),
                    
                      const SizedBox(height: 16),
                    
                      const Text(
                        'We spend more time on our phones than we mean to.\n'
                        'Not because we\'re weak — but because world keeps asking.',
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 16, // Smaller text
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B), // Softer color
                          height: 1.5,
                        ),
                      ),
                    
                      const SizedBox(height: 60),
                    
                      // CTA button - appears after delay
                      AnimatedOpacity(
                        opacity: _showButton ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: () {
                            // Simple fade-out transition (≈200ms)
                            Navigator.of(context).pushReplacementNamed('/main');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF64748B), // Calm color
                              borderRadius: BorderRadius.circular(25), // Soft rounded shape
                            ),
                            child: const Text(
                              'I feel this',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Subtle grain texture painter
class _SubtleGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03); // Very subtle
      ..style = PaintingStyle.fill;
    
    // Create static noise pattern
    for (int i = 0; i < 200; i++) {
      final x = (size.width * (i / 200.0));
      final y = (size.height * (i / 200.0));
      final opacity = (i % 2 == 0) ? 0.02 : 0.03;
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawRect(
        Rect.fromLTWH(x, y, 2, 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}