import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SkyLayer extends StatelessWidget {
  final bool isFocusing;

  const SkyLayer({super.key, required this.isFocusing});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. SKY (Top Gradient)
        AnimatedContainer(
          duration: const Duration(seconds: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Slight darkening focused state (evening feel) or standard day
                isFocusing ? const Color(0xFFB0C9CE) : AppColors.skyTop,
                isFocusing ? const Color(0xFFE8D5B5) : AppColors.skyBottom,
              ],
              stops: const [0.0, 0.7], // Sky ends before bottom
            ),
          ),
        ),
        
        // 2. HORIZON / DEEP SEA (Bottom fill)
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35, // Bottom 35% is sea
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Horizon Line Color -> Deep Sea
                  const Color(0xFFCFD8DC), // Matches Island Water Still
                  const Color(0xFF90A4AE), // Deeper Blue/Grey
                ],
              ),
            ),
          ),
        ),
        
        // 3. HORIZON BLEND (Soft Line)
        Align(
          alignment: Alignment(0, 0.3), // Roughly where sky meets sea (1.0 - 0.35*2 approx)
          child: Container(
            height: 2,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
