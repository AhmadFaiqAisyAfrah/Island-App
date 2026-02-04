import 'package:flutter/material.dart';
import 'dart:math' as math;

class StarScatter extends StatelessWidget {
  final int count;
  final Color baseColor;

  const StarScatter({
    super.key, 
    this.count = 50,
    this.baseColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPainter(count: count, color: baseColor),
      child: const SizedBox.expand(),
    );
  }
}

class _StarPainter extends CustomPainter {
  final int count;
  final Color color;

  _StarPainter({required this.count, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(101); // Fixed seed for consistent starscape
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      // Random position
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.7; // Keep mostly in top 70% of sky

      // Subtle Variance
      final sizeVar = random.nextDouble() * 1.5 + 0.5; // Size 0.5 to 2.0
      final opacityVar = random.nextDouble() * 0.4 + 0.1; // Opacity 0.1 to 0.5 (Very subtle)

      paint.color = color.withOpacity(opacityVar);
      canvas.drawCircle(Offset(x, y), sizeVar, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
