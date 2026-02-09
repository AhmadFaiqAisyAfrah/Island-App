import 'monetization_types.dart';

/// Represents a point transaction in the system
/// 
/// Immutable record of point changes with metadata.
/// Used for tracking economy state.
/// 
/// NOTE: This is a data model only. No UI logic.
class PointTransaction {
  /// Unique transaction ID
  final String id;
  
  /// Amount of points (positive = earned, negative = spent)
  final int amount;
  
  /// Type of source that generated this transaction
  final TransactionSource source;
  
  /// Optional reference ID (e.g., item ID if unlocking, session ID if focus)
  final String? referenceId;
  
  /// Human-readable description
  final String description;
  
  /// Timestamp when transaction occurred
  final DateTime timestamp;

  const PointTransaction({
    required this.id,
    required this.amount,
    required this.source,
    this.referenceId,
    required this.description,
    required this.timestamp,
  });

  /// Factory for earning points from focus session
  factory PointTransaction.fromFocusSession({
    required String id,
    required int durationMinutes,
    required String sessionId,
    required int pointsPerMinute,
  }) {
    final points = durationMinutes * pointsPerMinute;
    return PointTransaction(
      id: id,
      amount: points,
      source: TransactionSource.focusSession,
      referenceId: sessionId,
      description: 'Focus session completed ($durationMinutes min)',
      timestamp: DateTime.now(),
    );
  }

  /// Factory for earning points from watching ad
  factory PointTransaction.fromAdWatch({
    required String id,
    required AdsType adType,
    required int pointsReward,
  }) {
    return PointTransaction(
      id: id,
      amount: pointsReward,
      source: TransactionSource.adWatch,
      referenceId: adType.name,
      description: 'Watched ${adType.name} ad',
      timestamp: DateTime.now(),
    );
  }

  /// Factory for spending points to unlock item
  factory PointTransaction.forUnlock({
    required String id,
    required String itemId,
    required int cost,
  }) {
    return PointTransaction(
      id: id,
      amount: -cost,
      source: TransactionSource.itemUnlock,
      referenceId: itemId,
      description: 'Unlocked item: $itemId',
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() => 
      'PointTransaction(id: $id, amount: $amount, source: $source)';
}

/// Sources of point transactions
enum TransactionSource {
  /// Earned from completing focus session
  focusSession,
  
  /// Earned from watching advertisement
  adWatch,
  
  /// Spent to unlock item permanently
  itemUnlock,
  
  /// Manual adjustment (admin/debug)
  manualAdjustment,
  
  /// Starting bonus (new user)
  welcomeBonus,
}

/// Summary of point economy state
class PointBalance {
  /// Total points currently available
  final int currentPoints;
  
  /// Total points earned lifetime
  final int totalEarned;
  
  /// Total points spent lifetime
  final int totalSpent;
  
  /// Number of ads watched total
  final int totalAdsWatched;
  
  /// Last updated timestamp
  final DateTime lastUpdated;

  const PointBalance({
    required this.currentPoints,
    required this.totalEarned,
    required this.totalSpent,
    required this.totalAdsWatched,
    required this.lastUpdated,
  });

  /// Empty balance (for initialization)
  factory PointBalance.zero() => PointBalance(
    currentPoints: 0,
    totalEarned: 0,
    totalSpent: 0,
    totalAdsWatched: 0,
    lastUpdated: DateTime.now(),
  );
}
