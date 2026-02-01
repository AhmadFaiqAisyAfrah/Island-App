import 'dart:async';
import 'package:flutter/material.dart';
import '../../island/presentation/layers/island_base_layer.dart';
import '../../home/presentation/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 1.5s Fixed Duration (Calm Breath)
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Gentle Fade Transition
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800), // Slow fade
          ),
        );
      }
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
          // Minimal Logo (Code-Drawn Vector)
          // Responsive Scale: 40% of screen width
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoSize = constraints.maxWidth * 0.45; // 45% Width for confidence
              return CustomPaint(
                size: Size(logoSize, logoSize),
                painter: CalmLogoPainter(),
              );
            }
          ),
        ),
      ),
    );
  }
}

// Minimalist Vector Logo Painter
// Draws: Island Base + House + Tree
class CalmLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Island Base (Rounded Boat Shape)
    final islandPaint = Paint()
      ..color = const Color(0xFFB0BEC5) // Calm Grey-Blue (Island Base)
      ..style = PaintingStyle.fill;
    
    final islandPath = Path();
    islandPath.moveTo(w * 0.1, h * 0.6);
    // Draw rounded bottom
    islandPath.quadraticBezierTo(w * 0.5, h * 0.95, w * 0.9, h * 0.6);
    islandPath.lineTo(w * 0.1, h * 0.6);
    islandPath.close();
    canvas.drawPath(islandPath, islandPaint);

    // 2. House (Simple Beige Shape)
    final housePaint = Paint()
      ..color = const Color(0xFFE0D8CC) // Sand/Beige
      ..style = PaintingStyle.fill;
    
    final housePath = Path();
    // Body
    final houseW = w * 0.35;
    final houseH = h * 0.3;
    final houseL = w * 0.35; // centered-ish (shifted left)
    final houseB = h * 0.6; // sits on island line
    
    // Roof (Rounded Top)
    // Simple Box with rounded top
    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(houseL, houseB - houseH, houseW, houseH), 
      const Radius.circular(8)
    );
    canvas.drawRRect(rRect, housePaint);

    // Door (Small darker detail)
    final doorPaint = Paint()
      ..color = const Color(0xFF8D6E63).withOpacity(0.5) // Muted Brown
      ..style = PaintingStyle.fill;
    
    final doorW = houseW * 0.3;
    final doorH = houseH * 0.5;
    final doorRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(houseL + (houseW - doorW) / 2, houseB - doorH, doorW, doorH), 
      const Radius.circular(8) // Fully rounded top
    );
    canvas.drawRRect(doorRRect, doorPaint);

    // 3. Tree (Sage Green Blob)
    final treePaint = Paint()
      ..color = const Color(0xFF8DA399) // Sage Green
      ..style = PaintingStyle.fill;
    
    // Tree positions (Behind/Next to house?)
    // Let's put it to the left, slightly behind
    
    // Trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF6D6466) // Warm Grey
      ..style = PaintingStyle.fill;
    final trunkH = h * 0.2;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.25, h * 0.6 - trunkH, w * 0.05, trunkH), 
      trunkPaint
    );

    // Foliage (Circle)
    canvas.drawCircle(Offset(w * 0.275, h * 0.6 - trunkH), w * 0.12, treePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
