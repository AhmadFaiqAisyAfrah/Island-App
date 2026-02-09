/// Monetization Types & Enums
/// 
/// Defines all types used in Island's monetization system.
/// Pure data structures - no UI, no side effects.

/// Types of advertisements available in the app
enum AdsType {
  /// Ad shown to unlock trial period for an item
  /// Limited to 1 per day per user
  trialAd,
  
  /// Ad shown to earn points
  /// Unlimited, only available in shop context
  pointAd,
}

/// Access level types for items/themes/features
enum ItemAccessType {
  /// Completely free, no restrictions
  free,
  
  /// Available during trial period
  /// Requires watching trial ad first
  trial,
  
  /// Can be unlocked using accumulated points
  pointUnlock,
  
  /// Requires direct purchase (future Phase)
  premiumPurchase,
}

/// Duration options for trial periods
enum TrialDuration {
  /// 24-hour trial access
  oneDay,
  
  /// 7-day trial access
  oneWeek,
}

/// Extension methods for TrialDuration
extension TrialDurationExtension on TrialDuration {
  /// Get duration in hours
  int get hours {
    switch (this) {
      case TrialDuration.oneDay:
        return 24;
      case TrialDuration.oneWeek:
        return 168; // 7 * 24
    }
  }
  
  /// Get duration in days
  int get days {
    switch (this) {
      case TrialDuration.oneDay:
        return 1;
      case TrialDuration.oneWeek:
        return 7;
    }
  }
  
  /// Get human-readable label
  String get label {
    switch (this) {
      case TrialDuration.oneDay:
        return '1 Day';
      case TrialDuration.oneWeek:
        return '7 Days';
    }
  }
}
