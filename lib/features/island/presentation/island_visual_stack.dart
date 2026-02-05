import 'package:flutter/material.dart';
import '../../home/presentation/widgets/circular_duration_slider.dart';
import '../../../../core/theme/app_theme.dart';
import 'layers/sky_layer.dart';
import 'layers/ocean_layer.dart';
import 'layers/island_base_layer.dart';
import 'layers/glass_dome_layer.dart';

import '../../../../core/theme/theme_provider.dart';

class IslandVisualStack extends StatelessWidget {
  final bool isFocusing;
  final ThemeState themeState;
  
  // Slider / Progress Params
  final int currentSeconds; // Current setting OR remaining time
  final int totalSeconds;   // Max setting (7200) OR initial duration
  final ValueChanged<int>? onDurationChanged;
  final bool showSlider;
  final bool enableCharacterIdleMotion;

  const IslandVisualStack({
    super.key,
    required this.isFocusing,
    required this.themeState,
    required this.currentSeconds,
    required this.totalSeconds,
    this.onDurationChanged,
    this.showSlider = true,
    this.enableCharacterIdleMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        
        // Define sizes relative to width
        // Define sizes relative to width
        final islandWidth = w * 0.75;
        // Slider sits exactly on the dome scaling (1.15x).
        // Slider has internal padding of 8px per side (16px total).
        // To align track to dome border: Width = (Island * 1.15) + 16.
        final sliderWidth = (islandWidth * 1.15) + 16; 

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
                            width: islandWidth,
                            enableCharacterIdleMotion: enableCharacterIdleMotion,
                          ), 
                        );
                      },
                    ),

                    // A.5 REFLECTIVE FOCUS DOME (Animated Scale)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOutSine,
                      tween: Tween(
                        begin: 1.0, 
                        end: isFocusing ? 1.06 : 1.0
                      ),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: GlassDomeLayer(
                            width: islandWidth, 
                            themeState: themeState
                          ),
                        );
                      },
                    ),

                    if (showSlider)
                      TweenAnimationBuilder<double>(
                        duration: isFocusing
                            ? const Duration(milliseconds: 300)
                            : const Duration(milliseconds: 2300), // Wait for dome shrink (2000ms)
                        curve: isFocusing
                            ? Curves.easeOut
                            : const Interval(0.85, 1.0, curve: Curves.easeIn), // Late fade in
                        tween: Tween<double>(
                          begin: 1.0,
                          end: isFocusing ? 0.0 : 1.0
                        ),
                        builder: (context, opacity, child) {
                          return Opacity(
                            opacity: opacity,
                            child: IgnorePointer(
                              ignoring: opacity < 0.1 || isFocusing,
                              child: child,
                            ),
                          );
                        },
                        child: CircularDurationSlider(
                          width: sliderWidth,
                          currentCheckSeconds: currentSeconds,
                          totalSeconds: totalSeconds,
                          isFocusing: isFocusing,
                          themeState: themeState,
                          onDurationChanged: onDurationChanged,
                        ),
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
