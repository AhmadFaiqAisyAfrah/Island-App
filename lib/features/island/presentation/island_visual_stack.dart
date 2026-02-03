import 'package:flutter/material.dart';
import '../../home/presentation/widgets/circular_duration_slider.dart';
import '../../../../core/theme/app_theme.dart';
import 'layers/sky_layer.dart';
import 'layers/ocean_layer.dart';
import 'layers/island_base_layer.dart';

import '../../../../core/theme/theme_provider.dart';

class IslandVisualStack extends StatelessWidget {
  final bool isFocusing;
  final ThemeState themeState;
  
  // Slider / Progress Params
  final int currentSeconds; // Current setting OR remaining time
  final int totalSeconds;   // Max setting (7200) OR initial duration
  final ValueChanged<int>? onDurationChanged;

  const IslandVisualStack({
    super.key,
    required this.isFocusing,
    required this.themeState,
    required this.currentSeconds,
    required this.totalSeconds,
    this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        
        // Define sizes relative to width
        final islandWidth = w * 0.75;
        final sliderWidth = w * 0.86; // Reduced radius for breathing room

        return Stack(
          alignment: Alignment.center,
          children: [
            // 3. ISLAND & SLIDER GROUP
            Positioned(
              top: h * 0.20, // Moved up slightly to center the larger ring composition
              child: SizedBox(
                width: w,
                height: w, // Square area
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // A. The Island (Inner)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(seconds: 2), 
                      curve: Curves.easeInOutSine,
                      tween: Tween(
                        begin: 1.0, 
                        end: isFocusing ? 1.03 : 1.0 
                      ), 
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: IslandBaseLayer(
                            isFocusing: isFocusing, 
                            themeState: themeState,
                            width: islandWidth
                          ), 
                        );
                      },
                    ),

                    // B. The Slider (Outer Ring)
                    CircularDurationSlider(
                      width: sliderWidth,
                      currentCheckSeconds: currentSeconds,
                      totalSeconds: totalSeconds,
                      isFocusing: isFocusing,
                      themeState: themeState,
                      onDurationChanged: onDurationChanged,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
