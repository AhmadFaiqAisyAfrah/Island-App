import 'package:shared_preferences/shared_preferences.dart';
import '../domain/monetization/point_transaction.dart';
import '../domain/monetization/point_rules.dart';

/// Point Service - State Management for Point Economy
/// 
/// Manages point balance, transactions, and persistence.
/// NO UI, NO side effects, NO ad triggering.
/// 
/// Usage:
/// ```dart
/// final pointService = PointService(prefs);
/// final balance = pointService.getBalance();
/// ```
class PointService {
  final SharedPreferences _prefs;
  
  // SharedPreferences Keys
  static const String _keyTotalPoints = 'total_points';
  static const String _keyTotalEarned = 'total_points_earned';
  static const String _keyTotalSpent = 'total_points_spent';
  static const String _keyTotalAdsWatched = 'total_ads_watched';
  static const String _keyLastUpdated = 'points_last_updated';
  
  /// Constructor requires SharedPreferences instance
  PointService(this._prefs) {
    _seedStarterCoins();
  }

  /// Seed starter coins (50) for new users
  /// Runs only once when no existing points found
  void _seedStarterCoins() {
    final hasExistingData = _prefs.containsKey(_keyTotalPoints);
    if (!hasExistingData) {
      // New user - give 50 starter coins
      _prefs.setInt(_keyTotalPoints, 50);
      _prefs.setInt(_keyTotalEarned, 50);
      _prefs.setInt(_keyLastUpdated, DateTime.now().millisecondsSinceEpoch);
    }
  }
  
  /// Get current point balance
  int getCurrentPoints() {
    return _prefs.getInt(_keyTotalPoints) ?? 50; // Default to 50 if somehow null
  }
  
  /// Get total points earned lifetime
  int getTotalEarned() {
    return _prefs.getInt(_keyTotalEarned) ?? 0;
  }
  
  /// Get total points spent lifetime
  int getTotalSpent() {
    return _prefs.getInt(_keyTotalSpent) ?? 0;
  }
  
  /// Get total ads watched
  int getTotalAdsWatched() {
    return _prefs.getInt(_keyTotalAdsWatched) ?? 0;
  }
  
  /// Get complete point balance object
  PointBalance getBalance() {
    return PointBalance(
      currentPoints: getCurrentPoints(),
      totalEarned: getTotalEarned(),
      totalSpent: getTotalSpent(),
      totalAdsWatched: getTotalAdsWatched(),
      lastUpdated: _getLastUpdated(),
    );
  }
  
  /// Check if user has enough points for an unlock
  bool hasEnoughPoints(int cost) {
    return getCurrentPoints() >= cost;
  }
  
  /// Check if balance is above minimum unlock threshold
  bool canUnlockAnything() {
    return getCurrentPoints() >= PointThresholds.minimumUnlock;
  }
  
  /// Check if balance is low
  bool isLowBalance() {
    return getCurrentPoints() <= PointThresholds.lowBalance;
  }
  
  /// Add points (earn)
  /// 
  /// Returns true if successful
  Future<bool> addPoints(int amount) async {
    if (amount <= 0) return false;
    
    final current = getCurrentPoints();
    final earned = getTotalEarned();
    
    // Check max balance constraint
    final newTotal = current + amount;
    if (newTotal > PointConstraints.maxBalance) {
      return false;
    }
    
    final saved1 = await _prefs.setInt(_keyTotalPoints, newTotal);
    final saved2 = await _prefs.setInt(_keyTotalEarned, earned + amount);
    final saved3 = await _updateTimestamp();
    
    return saved1 && saved2 && saved3;
  }
  
  /// Spend points (unlock item)
  /// 
  /// Returns true if successful
  /// Returns false if insufficient balance
  Future<bool> spendPoints(int amount) async {
    if (amount <= 0) return false;
    
    final current = getCurrentPoints();
    
    // Check if has enough
    if (current < amount) return false;
    
    // Check if negative balance allowed
    if (!PointConstraints.allowNegative && current - amount < 0) {
      return false;
    }
    
    final spent = getTotalSpent();
    
    final saved1 = await _prefs.setInt(_keyTotalPoints, current - amount);
    final saved2 = await _prefs.setInt(_keyTotalSpent, spent + amount);
    final saved3 = await _updateTimestamp();
    
    return saved1 && saved2 && saved3;
  }
  
  /// Record ad watch (increments counter)
  /// 
  /// Call this after successful ad completion
  Future<bool> recordAdWatch() async {
    final current = getTotalAdsWatched();
    final saved1 = await _prefs.setInt(_keyTotalAdsWatched, current + 1);
    final saved2 = await _updateTimestamp();
    return saved1 && saved2;
  }
  
  /// Award welcome bonus (one-time)
  /// 
  /// Returns true if awarded, false if already claimed
  Future<bool> awardWelcomeBonus() async {
    const key = 'welcome_bonus_claimed';
    
    // Check if already claimed
    if (_prefs.getBool(key) ?? false) {
      return false;
    }
    
    // Award points
    final success = await addPoints(PointRewards.welcomeBonus);
    
    if (success) {
      // Mark as claimed
      await _prefs.setBool(key, true);
    }
    
    return success;
  }
  
  /// Award points for focus session
  /// 
  /// Automatically applies rules (min duration, max per session)
  Future<bool> awardFocusSessionPoints(int durationMinutes) async {
    // Check minimum duration
    if (durationMinutes < PointRewards.minimumFocusMinutes) {
      return false;
    }
    
    // Calculate points
    var points = durationMinutes * PointRewards.perFocusMinute;
    
    // Apply cap
    if (points > PointRewards.maxPerSession) {
      points = PointRewards.maxPerSession;
    }
    
    return await addPoints(points);
  }
  
  /// Award points for watching ad
  /// 
  /// Also increments ad watch counter
  Future<bool> awardAdWatchPoints() async {
    // Record ad watch
    await recordAdWatch();
    
    // Award points
    return await addPoints(PointRewards.perAdWatch);
  }
  
  /// Get points needed to unlock item
  /// 
  /// Returns 0 if already have enough
  int getPointsNeeded(int cost) {
    final current = getCurrentPoints();
    return cost > current ? cost - current : 0;
  }
  
  /// Calculate progress percentage toward an unlock
  /// 
  /// Returns 0.0 to 1.0
  double getUnlockProgress(int cost) {
    final current = getCurrentPoints();
    if (current >= cost) return 1.0;
    return current / cost;
  }
  
  /// Get transaction history (placeholder for future)
  /// 
  /// In Phase 1, transactions are not persisted individually.
  /// This is a hook for Phase 2 implementation.
  List<PointTransaction> getTransactionHistory() {
    // Phase 1: Return empty list
    // Phase 2: Implement proper transaction logging
    return [];
  }
  
  /// Get all point state for debugging
  Map<String, dynamic> getPointState() {
    return {
      'currentPoints': getCurrentPoints(),
      'totalEarned': getTotalEarned(),
      'totalSpent': getTotalSpent(),
      'totalAdsWatched': getTotalAdsWatched(),
      'canUnlockBasicTheme': hasEnoughPoints(PointCosts.basicTheme),
      'canUnlockPremiumTheme': hasEnoughPoints(PointCosts.premiumTheme),
      'isLowBalance': isLowBalance(),
    };
  }
  
  // Private helper methods
  
  DateTime _getLastUpdated() {
    final timestamp = _prefs.getInt(_keyLastUpdated);
    if (timestamp == null) return DateTime.now();
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  Future<bool> _updateTimestamp() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return await _prefs.setInt(_keyLastUpdated, timestamp);
  }
}
