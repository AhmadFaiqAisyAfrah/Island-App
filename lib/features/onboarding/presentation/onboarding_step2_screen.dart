import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingStep2Screen extends StatefulWidget {
  const OnboardingStep2Screen({super.key});

  @override
  State<OnboardingStep2Screen> createState() => _OnboardingStep2ScreenState();
}

class _OnboardingStep2ScreenState extends State<OnboardingStep2Screen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentState = 1; // Start with STATE 1

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _advanceToNextState() {
    _fadeController.forward().then((_) {
      setState(() {
        _currentState++;
      });
      _fadeController.reset();
      _fadeController.forward();
    });
  }

  Widget _buildState1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'What should we call you?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Color(0xFF2C3E50),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'It doesn\'t have to be perfect.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 60),
        // Single text input with placeholder
        Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        // CTA button
        AnimatedOpacity(
          opacity: _fadeAnimation.value,
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: _advanceToNextState,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64748B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
            child: const Text(
              'That\'s fine',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildState2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'How much time do you spend on your phone each day?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Color(0xFF2C3E50),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'No judgment. Just awareness.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 60),
        // Single select options
        Column(
          children: [
            _buildPhoneOption('Less than 3 hours'),
            const SizedBox(height: 12),
            _buildPhoneOption('3–5 hours'),
            const SizedBox(height: 12),
            _buildPhoneOption('5–8 hours'),
            const SizedBox(height: 12),
            _buildPhoneOption('More than 8 hours'),
          ],
        ),
        const SizedBox(height: 40),
        // CTA button
        AnimatedOpacity(
          opacity: _fadeAnimation.value,
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: _advanceToNextState,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64748B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
            child: const Text(
              'Be honest',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildState3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'What usually keeps you on your phone?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Color(0xFF2C3E50),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'You can choose more than one.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 60),
        // Multi-select options
        Column(
          children: [
            _buildReasonOption('Stress or overwhelm'),
            const SizedBox(height: 12),
            _buildReasonOption('Work or study pressure'),
            const SizedBox(height: 12),
            _buildReasonOption('Escaping boredom'),
            const SizedBox(height: 12),
            _buildReasonOption('Social expectations'),
            const SizedBox(height: 12),
            _buildReasonOption('I\'m not sure'),
          ],
        ),
        const SizedBox(height: 40),
        // CTA button
        AnimatedOpacity(
          opacity: _fadeAnimation.value,
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: _advanceToNextState,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64748B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
            child: const Text(
              'That makes sense',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneOption(String text) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF2C3E50),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildReasonOption(String text) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF2C3E50),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildCurrentState() {
    switch (_currentState) {
      case 1:
        return _buildState1();
      case 2:
        return _buildState2();
      case 3:
        return _buildState3();
      default:
        return const SizedBox.shrink();
    }
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
                    const Color(0xFF1a1a2e),
                    const Color(0xFF2d2d44),
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFE9ECEF),
                  ],
          ),
        ),
        // Subtle grain/noise texture
        child: CustomPaint(
          painter: _SubtleGrainPainter(),
          child: SafeArea(
            child: Stack(
              children: [
                // Current state content
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentState(),
                  ),
                ),
                
                // Skip button in top-right corner
                Positioned(
                  top: 20,
                  right: 20,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigation placeholder
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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

// Reuse the subtle grain painter from step 1
class _SubtleGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
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