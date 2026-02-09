import 'monetization_types.dart';

/// Represents an item that can be unlocked via trial
/// 
/// Stores metadata about trialable items including:
/// - Unique identifier
/// - Display name
/// - Access type
/// - Trial duration
/// 
/// NOTE: This is a data model only. No UI logic.
class TrialItem {
  /// Unique identifier (e.g., 'theme_ocean', 'island_sakura')
  final String id;
  
  /// Human-readable name
  final String name;
  
  /// Type of access required
  final ItemAccessType accessType;
  
  /// Trial duration (only relevant if accessType == trial)
  final TrialDuration trialDuration;
  
  /// Points required to unlock permanently (if pointUnlock)
  final int? pointCost;
  
  /// Premium purchase price in local currency (future)
  final double? purchasePrice;
  
  /// Category for grouping (e.g., 'theme', 'island_style', 'music')
  final String category;
  
  /// Whether this is a regular (non-premium) item
  /// Trial ads only work on regular items
  final bool isRegular;

  const TrialItem({
    required this.id,
    required this.name,
    required this.accessType,
    this.trialDuration = TrialDuration.oneDay,
    this.pointCost,
    this.purchasePrice,
    this.category = 'general',
    this.isRegular = true,
  });

  /// Check if this item supports trial access
  bool get supportsTrial => accessType == ItemAccessType.trial && isRegular;
  
  /// Check if this item can be unlocked with points
  bool get supportsPointUnlock => accessType == ItemAccessType.pointUnlock && pointCost != null;
  
  /// Check if this item requires premium purchase
  bool get requiresPurchase => accessType == ItemAccessType.premiumPurchase;

  @override
  String toString() => 'TrialItem(id: $id, name: $name, accessType: $accessType)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrialItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
