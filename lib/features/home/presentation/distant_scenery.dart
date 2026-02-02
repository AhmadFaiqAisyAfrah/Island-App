import 'package:flutter/material.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'dart:math' as math;

class DistantScenery extends StatelessWidget {
  final ThemeState themeState;

  const DistantScenery({super.key, required this.themeState});

  @override
  Widget build(BuildContext context) {
    if (themeState.environment == AppEnvironment.defaultSky) {
      return const SizedBox.shrink(); 
    }

    return IgnorePointer(
      child: CustomPaint(
        painter: _SceneryPainter(
          environment: themeState.environment,
          isNight: themeState.mode == AppThemeMode.night,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SceneryPainter extends CustomPainter {
  final AppEnvironment environment;
  final bool isNight;

  _SceneryPainter({required this.environment, required this.isNight});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final Paint paint = Paint();

    switch (environment) {
      case AppEnvironment.mountain:
        _drawMountains(canvas, w, h, paint);
        break;
      case AppEnvironment.forest:
        _drawForest(canvas, w, h, paint);
        break;
      case AppEnvironment.beach:
        _drawBeach(canvas, w, h, paint);
        break;
      case AppEnvironment.space:
        _drawSpace(canvas, w, h, paint);
        break;
      default:
        break;
    }
  }

  void _drawMountains(Canvas canvas, double w, double h, Paint paint) {
    // Distant mountains silhouette
    final Path path = Path();
    path.moveTo(0, h);
    path.lineTo(0, h * 0.65);
    
    // Simple jagged peaks
    path.lineTo(w * 0.2, h * 0.55);
    path.lineTo(w * 0.4, h * 0.65);
    path.lineTo(w * 0.6, h * 0.50); // Tallest peak
    path.lineTo(w * 0.8, h * 0.60);
    path.lineTo(w, h * 0.55);
    path.lineTo(w, h);
    path.close();

    paint.color = isNight 
      ? const Color(0xFF161819).withOpacity(0.8) // Dark silhouette
      : const Color(0xFFC8C8D8).withOpacity(0.4); // Misty aesthetic
      
    canvas.drawPath(path, paint);
  }

  void _drawForest(Canvas canvas, double w, double h, Paint paint) {
    // Rolling hills/trees
    final Path path = Path();
    path.moveTo(0, h);
    path.lineTo(0, h * 0.60);
    
    // Sine wave for tree tops
    for (double x = 0; x <= w; x += 10) {
      path.lineTo(x, (h * 0.60) + math.sin(x * 0.05) * 10);
    }
    
    path.lineTo(w, h);
    path.close();

    paint.color = isNight 
      ? const Color(0xFF0F2018).withOpacity(0.8) 
      : const Color(0xFFB8C6BF).withOpacity(0.5); 
      
    canvas.drawPath(path, paint);
  }

  void _drawBeach(Canvas canvas, double w, double h, Paint paint) {
    // Horizon line (Ocean)
    final Rect oceanRect = Rect.fromLTWH(0, h * 0.65, w, h * 0.35);
    paint.color = isNight 
      ? const Color(0xFF1A2A3A).withOpacity(0.8) 
      : const Color(0xFF4FA4F2).withOpacity(0.3);
    canvas.drawRect(oceanRect, paint);
  }

  void _drawSpace(Canvas canvas, double w, double h, Paint paint) {
    // Stars
    final random = math.Random(123);
    paint.color = Colors.white.withOpacity(isNight ? 0.6 : 0.2);
    
    for (int i = 0; i < 100; i++) {
        double x = random.nextDouble() * w;
        double y = random.nextDouble() * h * 0.6; // Top 60% only
        double r = random.nextDouble() * 2;
        canvas.drawCircle(Offset(x,y), r, paint);
    }
    
    // Maybe a Planet?
    paint.color = isNight 
        ? const Color(0xFFE0E0E0).withOpacity(0.1) // Moon-ish
        : const Color(0xFFFFD700).withOpacity(0.1); // Sun-ish
        
    canvas.drawCircle(Offset(w * 0.8, h * 0.2), 40, paint);
  }

  @override
  bool shouldRepaint(covariant _SceneryPainter oldDelegate) {
    return oldDelegate.environment != environment || oldDelegate.isNight != isNight;
  }
}
