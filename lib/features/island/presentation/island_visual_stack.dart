import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'layers/sky_layer.dart';
import 'layers/ocean_layer.dart';
import 'layers/island_base_layer.dart';

class IslandVisualStack extends StatelessWidget {
  final bool isFocusing;

  const IslandVisualStack({
    super.key,
    required this.isFocusing,
  });

  @override
  Widget build(BuildContext context) {
    // 2.5D Illusion using Stack + Transform
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. SKY (Moved to HomeScreen for guaranteed fill)


            // 2. OCEAN REMOVED (Handled by Global Gradient)

            // 3. ISLAND (Core Subject)
            // Centered but slightly lower to ground it
            Positioned(
              top: h * 0.25, // More breathing room
              child: TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2), 
                curve: Curves.easeInOutSine,
                tween: Tween(
                  begin: 1.0, 
                  end: isFocusing ? 1.05 : 1.0
                ), 
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: IslandBaseLayer(isFocusing: isFocusing, width: w * 0.75), // REDUCED SCALE (0.9 -> 0.75)
                  );
                },
              ),
            ),

            // 4. WARMTH OVERLAY (Focus State only)
            if (isFocusing)
              IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(seconds: 4),
                  opacity: 0.15, // Subtle warm tint
                  child: Container(color: AppColors.warmOverlay),
                ),
              ),
          ],
        );
      },
    );
  }
}
