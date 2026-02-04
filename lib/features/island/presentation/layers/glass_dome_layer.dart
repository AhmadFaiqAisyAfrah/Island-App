import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';

class GlassDomeLayer extends StatelessWidget {
  final double width;
  final ThemeState themeState;

  const GlassDomeLayer({
    super.key,
    required this.width,
    required this.themeState,
  });

  @override
  Widget build(BuildContext context) {
    // Dome is slightly larger than the island bounds to encase it
    final double domeSize = width * 1.15; 
    final isNight = themeState.mode == AppThemeMode.night;

    // Static Container (Scale is animated by parent)
    return Container(
      width: domeSize,
      height: domeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Glass Surface Gradient (Constant Subtle)
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.0), // Center is clear
            Colors.white.withOpacity(isNight ? 0.08 : 0.04), // Edges catch faint light
          ],
          stops: const [0.7, 1.0],
        ),
        // Subtle Outline (Constant)
        border: Border.all(
          color: Colors.white.withOpacity(isNight ? 0.15 : 0.1),
          width: 1.5,
        ),
      ),
      child: CustomPaint(
        painter: _GlassReflectionPainter(isNight: isNight),
      ),
    );
  }
}

class _GlassReflectionPainter extends CustomPainter {
  final bool isNight;

  _GlassReflectionPainter({required this.isNight});
  
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // 1. PRIMARY HIGHLIGHT (Top Left - Light Source)
    // Sharper, brighter reflection of the main light
    final primaryOpacity = isNight ? 0.25 : 0.2;
    final primaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6) 
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(primaryOpacity),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.4],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final pathPrimary = Path();
    final margin = w * 0.04;
    pathPrimary.addArc(
      Rect.fromLTWH(margin, margin, w - margin*2, h - margin*2), 
      math.pi * 1.05, // 10:30 position
      math.pi * 0.25  // Short crisp arc
    );
    canvas.drawPath(pathPrimary, primaryPaint);

    // 1.5 PRIMARY HOTSPOT (Inner core)
    // Adds a tiny bit of "gloss" to the highlight
    final hotspotPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.01
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
      ..color = Colors.white.withOpacity(isNight ? 0.4 : 0.3);

    final pathHotspot = Path();
    pathHotspot.addArc(
      Rect.fromLTWH(margin, margin, w - margin*2, h - margin*2), 
      math.pi * 1.1, 
      math.pi * 0.1 // Very short
    );
    canvas.drawPath(pathHotspot, hotspotPaint);


    // 2. RIM LIGHT (Bottom Right - Refraction)
    // Softer, wider, indicates volume on the shadow side
    final rimOpacity = isNight ? 0.12 : 0.08;
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10) // Very soft
      ..shader = LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        colors: [
          Colors.white.withOpacity(rimOpacity),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final pathRim = Path();
    pathRim.addArc(
      Rect.fromLTWH(margin, margin, w - margin*2, h - margin*2), 
      math.pi * -0.2, // ~4:00 - 5:00 position
      math.pi * 0.4 
    );
    canvas.drawPath(pathRim, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _GlassReflectionPainter oldDelegate) {
    return oldDelegate.isNight != isNight;
  }
}
