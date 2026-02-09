/// Point Economy Rules - Pure Constants
/// 
/// Defines the economy of the Island point system.
/// NO execution logic, NO side effects.
/// 
/// These are the exchange rates and thresholds.

/// Point Rewards
/// 
/// How points are earned
class PointRewards {
  /// Points earned per minute of focused time
  static const int perFocusMinute = 2;
  
  /// Minimum focus session to earn points (in minutes)
  static const int minimumFocusMinutes = 5;
  
  /// Maximum points per focus session (cap)
  static const int maxPerSession = 100;
  
  /// Bonus for streak (consecutive days)
  static const int streakBonusPerDay = 10;
  
  /// Maximum streak bonus
  static const int maxStreakBonus = 50;
  
  /// Points per ad watched (see AdsPolicy for details)
  static const int perAdWatch = 50;
  
  /// Welcome bonus for new users
  static const int welcomeBonus = 100;
  
  /// Private constructor
  const PointRewards._();
}

/// Point Costs
/// 
/// How points are spent
class PointCosts {
  /// Cost to unlock a basic theme
  static const int basicTheme = 500;
  
  /// Cost to unlock a premium theme
  static const int premiumTheme = 1000;
  
  /// Cost to unlock island style variation
  static const int islandStyle = 750;
  
  /// Cost to unlock special music track
  static const int musicTrack = 300;
  
  /// Private constructor
  const PointCosts._();
}

/// Point Thresholds
/// 
/// Important point values for UI/state logic
class PointThresholds {
  /// Minimum points needed to unlock anything
  static const int minimumUnlock = 300;
  
  /// "Low balance" warning threshold
  static const int lowBalance = 100;
  
  /// "Rich" user threshold (for future gamification)
  static const int highBalance = 2000;
  
  /// Private constructor
  const PointThresholds._();
}

/// Point Economy Constraints
/// 
/// System-wide economic rules
class PointConstraints {
  /// Maximum points a user can hold (prevent overflow)
  static const int maxBalance = 99999;
  
  /// Whether points can go negative
  static const bool allowNegative = false;
  
  /// Do unspent points expire?
  static const bool pointsExpire = false;
  
  /// If points expire, how long? (days)
  static const int? expirationDays = null;
  
  /// Private constructor
  const PointConstraints._();
}
