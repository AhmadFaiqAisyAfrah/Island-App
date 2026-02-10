import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Pastel / Gouache Palette
  static const Color skyTop = Color(0xFFF2F4F6);    // Soft dove gray
  static const Color skyBottom = Color(0xFFF2F4F6); // Soft dove gray
  
  static const Color oceanSurface = Color(0xFFA8D5E2); // Calm water
  static const Color oceanDeep = Color(0xFF7FB5C9);    // Slightly deeper water
  
  static const Color islandGrass = Color(0xFFB5D491);  // Soft matcha green
  static const Color islandCliff = Color(0xFF8B9D77);  // Shadowed green/brown
  static const Color islandBeige = Color(0xFFE6D5B8);  // Sand/Earth
  
  static const Color textMain = Color(0xFF5F6B7A);     // Same as time slider, dark soft blue-gray
  static const Color textSub = Color(0xFF6B6B6B);      // Medium gray
  
  static const Color warmOverlay = Color(0xFFFFB347);  // For focus state (orange tint)
}

class AppTextStyles {
  // Calm, rounded typography
  static TextStyle get heading => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
    letterSpacing: -0.5,
  );
  
  static TextStyle get subHeading => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textMain,
  );

  static TextStyle get body => GoogleFonts.quicksand( // Friendly, rounded
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textMain,
  );
  
  static TextStyle get timer => GoogleFonts.outfit(
    fontSize: 72,
    fontWeight: FontWeight.w200, // Very thin and elegant
    letterSpacing: 2.0,
    color: Color(0xFF5F6B7A), // Same as main text color
  );

  static List<Shadow> get softShadow => [
    Shadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8.0,
      offset: const Offset(0, 2),
    ),
  ];
}

class AppTheme {
  static ThemeData get pastelTheme => ThemeData(
    primaryColor: AppColors.islandGrass,
    scaffoldBackgroundColor: AppColors.skyBottom, 
    textTheme: TextTheme(
      displayLarge: AppTextStyles.heading,
      bodyLarge: AppTextStyles.body,
    ),
    useMaterial3: true,
  );
}
