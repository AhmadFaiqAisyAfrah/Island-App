import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OceanLayer extends StatefulWidget {
  final bool isFocusing;

  const OceanLayer({super.key, required this.isFocusing});

  @override
  State<OceanLayer> createState() => _OceanLayerState();
}

class _OceanLayerState extends State<OceanLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // Very slow breath
    );
    if (widget.isFocusing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(OceanLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFocusing != oldWidget.isFocusing) {
      if (widget.isFocusing) {
        _controller.repeat(reverse: true);
      } else {
        // Gently stop the waves
        _controller.animateTo(0.5, duration: const Duration(seconds: 3), curve: Curves.easeInOut);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Just a smooth, full-screen atmospheric gradient
    // No "water line" or path drawing to avoid artifacts.
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.0), // Sky at top
            AppColors.oceanSurface.withOpacity(0.8), // Deep ocean at bottom
          ],
          stops: const [0.0, 1.0], // Smooth fade all the way down
        ),
      ),
    );
  }
}
// Removed OceanPainter class entirely to prevent artifacts.
