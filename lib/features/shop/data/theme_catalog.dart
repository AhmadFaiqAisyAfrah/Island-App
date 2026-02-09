import 'package:flutter/material.dart';
import '../../../domain/monetization/monetization.dart';

/// Extended Theme Item with Monetization Metadata
/// 
/// Wraps existing theme data with monetization state.
/// Used in Shop and Theme Selector for visual indicators.
class MonetizableThemeItem {
  /// Unique identifier (matches theme identifiers)
  final String id;
  
  /// Display name
  final String name;
  
  /// Asset path for preview image
  final String assetPath;
  
  /// Accent color for the theme
  final Color accentColor;
  
  /// Access type (free, trial, pointUnlock, premium)
  final ItemAccessType accessType;
  
  /// Points required to unlock (if pointUnlock)
  final int? pointCost;
  
  /// Whether this item supports trial
  final bool supportsTrial;
  
  /// Category for grouping
  final String category;
  
  /// Description for shop display
  final String description;

  const MonetizableThemeItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.accentColor,
    this.accessType = ItemAccessType.free,
    this.pointCost,
    this.supportsTrial = false,
    this.category = 'general',
    this.description = '',
  });

  /// Check if this item is currently locked
  bool get isLocked => accessType != ItemAccessType.free;
  
  /// Check if unlockable with points
  bool get isPointUnlock => accessType == ItemAccessType.pointUnlock && pointCost != null;
  
  /// Check if requires real money purchase
  bool get isPremium => accessType == ItemAccessType.premiumPurchase;
  
  /// Check if trial is available
  bool get isTrialAvailable => supportsTrial && accessType == ItemAccessType.trial;

  @override
  String toString() => 'MonetizableThemeItem(id: $id, name: $name, accessType: $accessType)';
}

/// Theme Catalog - All available themes with monetization data
/// 
/// This is a static catalog. Real unlock state is stored in services.
class ThemeCatalog {
  /// Seasonal Themes
  static List<MonetizableThemeItem> get seasonal => [
    const MonetizableThemeItem(
      id: 'season_normal',
      name: 'Original',
      assetPath: 'assets/themes/original_season.png',
      accentColor: Color(0xFFB5D491),
      accessType: ItemAccessType.free,
      category: 'seasonal',
      description: 'The classic Island experience',
    ),
    const MonetizableThemeItem(
      id: 'season_sakura',
      name: 'Sakura',
      assetPath: 'assets/themes/sakura_season.png',
      accentColor: Color(0xFFFFC0CB),
      accessType: ItemAccessType.trial,
      supportsTrial: true,
      category: 'seasonal',
      description: 'Cherry blossom season',
    ),
    const MonetizableThemeItem(
      id: 'season_autumn',
      name: 'Autumn',
      assetPath: 'assets/themes/autumn_season.png',
      accentColor: Color(0xFFD48C70),
      accessType: ItemAccessType.pointUnlock,
      pointCost: 500,
      supportsTrial: true,
      category: 'seasonal',
      description: 'Warm autumn colors',
    ),
    const MonetizableThemeItem(
      id: 'season_winter',
      name: 'Winter',
      assetPath: 'assets/themes/winter_season.png',
      accentColor: Color(0xFFB0E0E6),
      accessType: ItemAccessType.pointUnlock,
      pointCost: 750,
      supportsTrial: true,
      category: 'seasonal',
      description: 'Serene winter landscape',
    ),
  ];

  /// Environment Themes
  static List<MonetizableThemeItem> get environments => [
    const MonetizableThemeItem(
      id: 'env_default',
      name: 'Ocean View',
      assetPath: 'assets/themes/default_sky.png',
      accentColor: Color(0xFF87CEEB),
      accessType: ItemAccessType.free,
      category: 'environment',
      description: 'Calm ocean backdrop',
    ),
    const MonetizableThemeItem(
      id: 'env_mountain',
      name: 'Mountain',
      assetPath: 'assets/themes/mountain.png',
      accentColor: Color(0xFF8FBC8F),
      accessType: ItemAccessType.pointUnlock,
      pointCost: 500,
      supportsTrial: true,
      category: 'environment',
      description: 'Majestic mountain view',
    ),
    const MonetizableThemeItem(
      id: 'env_beach',
      name: 'Tropical Beach',
      assetPath: 'assets/themes/beach.png',
      accentColor: Color(0xFFF4A460),
      accessType: ItemAccessType.premiumPurchase,
      category: 'environment',
      description: 'Premium tropical paradise',
    ),
    const MonetizableThemeItem(
      id: 'env_forest',
      name: 'Deep Forest',
      assetPath: 'assets/themes/forest.png',
      accentColor: Color(0xFF228B22),
      accessType: ItemAccessType.pointUnlock,
      pointCost: 600,
      supportsTrial: true,
      category: 'environment',
      description: 'Mystical forest setting',
    ),
  ];

  /// House Variants
  static List<MonetizableThemeItem> get houses => [
    const MonetizableThemeItem(
      id: 'house_default',
      name: 'Cozy Cottage',
      assetPath: 'assets/themes/house_default.png',
      accentColor: Color(0xFFD2B48C),
      accessType: ItemAccessType.free,
      category: 'house',
      description: 'Your starter home',
    ),
    const MonetizableThemeItem(
      id: 'house_adventure',
      name: 'Adventure House',
      assetPath: 'assets/themes/house_adventure.png',
      accentColor: Color(0xFFCD853F),
      accessType: ItemAccessType.pointUnlock,
      pointCost: 800,
      supportsTrial: true,
      category: 'house',
      description: 'For the explorer',
    ),
    const MonetizableThemeItem(
      id: 'house_stargazer',
      name: 'Stargazer Hut',
      assetPath: 'assets/themes/house_stargazer.png',
      accentColor: Color(0xFF4B0082),
      accessType: ItemAccessType.premiumPurchase,
      category: 'house',
      description: 'Premium celestial dwelling',
    ),
    const MonetizableThemeItem(
      id: 'house_forest',
      name: 'Forest Cabin',
      assetPath: 'assets/themes/house_forest.png',
      accentColor: Color(0xFF556B2F),
      accessType: ItemAccessType.pointUnlock,
      pointCost: 700,
      supportsTrial: true,
      category: 'house',
      description: 'Hidden in the woods',
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
