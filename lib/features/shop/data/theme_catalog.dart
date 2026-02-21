import 'package:flutter/material.dart';

/// Theme Item with Monetization Metadata
/// 
/// Simple model: price (int) + isDefault (bool).
/// Default themes are always unlocked. Non-default require coin purchase.
class MonetizableThemeItem {
  /// Unique identifier (matches theme enum values)
  final String id;
  
  /// Display name
  final String name;
  
  /// Asset path for preview image
  final String assetPath;
  
  /// Accent color for the theme
  final Color accentColor;
  
  /// Price in coins (0 for free/default themes)
  final int price;
  
  /// Whether this is a default (always-unlocked) theme
  final bool isDefault;
  
  /// Category for grouping
  final String category;

  const MonetizableThemeItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.accentColor,
    this.price = 0,
    this.isDefault = false,
    this.category = 'general',
  });

  @override
  String toString() => 'MonetizableThemeItem(id: $id, name: $name, price: $price, isDefault: $isDefault)';
}

/// Theme Catalog — All available themes with pricing
/// 
/// Static catalog. Real unlock state is stored in ThemeUnlockService.
class ThemeCatalog {
  /// Seasonal Themes
  static List<MonetizableThemeItem> get seasonal => [
    const MonetizableThemeItem(
      id: 'season_normal',
      name: 'Original',
      assetPath: 'assets/themes/original_season.png',
      accentColor: Color(0xFFB5D491),
      price: 0,
      isDefault: true,
      category: 'seasonal',
    ),
    const MonetizableThemeItem(
      id: 'season_sakura',
      name: 'Sakura',
      assetPath: 'assets/themes/sakura_season.png',
      accentColor: Color(0xFFFFC0CB),
      price: 300,
      isDefault: false,
      category: 'seasonal',
    ),
    const MonetizableThemeItem(
      id: 'season_autumn',
      name: 'Autumn',
      assetPath: 'assets/themes/autumn_season.png',
      accentColor: Color(0xFFD48C70),
      price: 600,
      isDefault: false,
      category: 'seasonal',
    ),
    const MonetizableThemeItem(
      id: 'season_winter',
      name: 'Winter',
      assetPath: 'assets/themes/winter_season.png',
      accentColor: Color(0xFFB0E0E6),
      price: 600,
      isDefault: false,
      category: 'seasonal',
    ),
  ];

  /// Environment Themes
  static List<MonetizableThemeItem> get environments => [
    const MonetizableThemeItem(
      id: 'env_default',
      name: 'Ocean View',
      assetPath: 'assets/themes/default_sky.png',
      accentColor: Color(0xFF87CEEB),
      price: 0,
      isDefault: true,
      category: 'environment',
    ),
    const MonetizableThemeItem(
      id: 'env_mountain',
      name: 'Mountain',
      assetPath: 'assets/themes/mountain.png',
      accentColor: Color(0xFF8FBC8F),
      price: 300,
      isDefault: false,
      category: 'environment',
    ),
    const MonetizableThemeItem(
      id: 'env_beach',
      name: 'Tropical Beach',
      assetPath: 'assets/themes/beach.png',
      accentColor: Color(0xFFF4A460),
      price: 600,
      isDefault: false,
      category: 'environment',
    ),
    const MonetizableThemeItem(
      id: 'env_forest',
      name: 'Deep Forest',
      assetPath: 'assets/themes/forest.png',
      accentColor: Color(0xFF228B22),
      price: 900,
      isDefault: false,
      category: 'environment',
    ),
  ];

  /// House Variants
  static List<MonetizableThemeItem> get houses => [
    const MonetizableThemeItem(
      id: 'house_default',
      name: 'Cozy Cottage',
      assetPath: 'assets/themes/house_default.png',
      accentColor: Color(0xFFD2B48C),
      price: 0,
      isDefault: true,
      category: 'house',
    ),
    const MonetizableThemeItem(
      id: 'house_adventure',
      name: 'Adventure House',
      assetPath: 'assets/themes/house_adventure.png',
      accentColor: Color(0xFFCD853F),
      price: 400,
      isDefault: false,
      category: 'house',
    ),
    const MonetizableThemeItem(
      id: 'house_stargazer',
      name: 'Stargazer Hut',
      assetPath: 'assets/themes/house_stargazer.png',
      accentColor: Color(0xFF4B0082),
      price: 800,
      isDefault: false,
      category: 'house',
    ),
    const MonetizableThemeItem(
      id: 'house_forest',
      name: 'Forest Cabin',
      assetPath: 'assets/themes/house_forest.png',
      accentColor: Color(0xFF556B2F),
      price: 1200,
      isDefault: false,
      category: 'house',
    ),
  ];

  /// All themes combined
  static List<MonetizableThemeItem> get all => [
    ...seasonal,
    ...environments,
    ...houses,
  ];

  /// Get theme by ID
  static MonetizableThemeItem? getById(String id) {
    try {
      return all.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
