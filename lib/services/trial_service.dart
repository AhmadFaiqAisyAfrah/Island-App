import 'package:shared_preferences/shared_preferences.dart';
import '../domain/monetization/trial_item.dart';

/// Trial Service - State Management for Trial System
/// 
/// Manages trial state persistence and business logic.
/// NO UI, NO side effects, NO ad triggering.
/// 
/// Usage:
/// ```dart
/// final trialService = TrialService(prefs);
/// if (trialService.canShowTrialOfferToday()) { ... }
/// ```
class TrialService {
  final SharedPreferences _prefs;
  
  // SharedPreferences Keys
  static const String _keyLastTrialAdDate = 'trial_last_shown_date';
  static const String _keyTrialActiveUntil = 'trial_active_until';
  static const String _keyTrialItemId = 'trial_item_id';
  
  /// Constructor requires SharedPreferences instance
  TrialService(this._prefs);
  
  /// Check if trial offer can be shown today
  /// 
  /// Returns true if:
  /// - No trial ad shown today
  /// - Cooldown period has passed
  bool canShowTrialOfferToday() {
    final lastShown = getLastTrialAdDate();
    if (lastShown == null) return true;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastShownDay = DateTime(lastShown.year, lastShown.month, lastShown.day);
    
    // Check if last shown was on a different day
    return !lastShownDay.isAtSameMomentAs(today);
  }
  
  /// Check if user has an active trial
  bool hasActiveTrial() {
    final activeUntil = getTrialActiveUntil();
    if (activeUntil == null) return false;
    
    return DateTime.now().isBefore(activeUntil);
  }
  
  /// Check if trial is active for a specific item
  /// 
  /// Returns true only if:
  /// - Trial is currently active
  /// - Trial is for the specified item
  bool isTrialActiveFor(String itemId) {
    if (!hasActiveTrial()) return false;
    
    final activeItemId = getTrialItemId();
    return activeItemId == itemId;
  }
  
  /// Check if user can start trial for an item
  /// 
  /// Returns true if:
  /// - Item supports trial
  /// - No active trial for different item
  /// - Daily limit not reached
  bool canStartTrialFor(TrialItem item) {
    // Item must support trial
    if (!item.supportsTrial) return false;
    
    // Check daily limit
    if (!canShowTrialOfferToday()) return false;
    
    // If has active trial, must be for same item
    if (hasActiveTrial()) {
      return isTrialActiveFor(item.id);
    }
    
    return true;
  }
  
  /// Get date when last trial ad was shown
  DateTime? getLastTrialAdDate() {
    final timestamp = _prefs.getInt(_keyLastTrialAdDate);
    if (timestamp == null) return null;
    
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  /// Get trial expiration date
  DateTime? getTrialActiveUntil() {
    final timestamp = _prefs.getInt(_keyTrialActiveUntil);
    if (timestamp == null) return null;
    
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  /// Get ID of item currently on trial
  String? getTrialItemId() {
    return _prefs.getString(_keyTrialItemId);
  }
  
  /// Record that trial ad was shown today
  /// 
  /// Call this AFTER ad is successfully shown
  /// Returns true if saved successfully
  Future<bool> recordTrialAdShown() async {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return await _prefs.setInt(_keyLastTrialAdDate, timestamp);
  }
  
  /// Activate trial for an item
  /// 
  /// Call this AFTER user completes watching trial ad
  /// Returns true if saved successfully
  Future<bool> activateTrial({
    required String itemId,
    required int durationHours,
  }) async {
    final now = DateTime.now();
    final activeUntil = now.add(Duration(hours: durationHours));
    final timestamp = activeUntil.millisecondsSinceEpoch;
    
    final saved1 = await _prefs.setInt(_keyTrialActiveUntil, timestamp);
    final saved2 = await _prefs.setString(_keyTrialItemId, itemId);
    
    return saved1 && saved2;
  }
  
  /// Deactivate current trial (expire it)
  /// 
  /// Can be used for admin/debug or early termination
  Future<bool> deactivateTrial() async {
    final removed1 = await _prefs.remove(_keyTrialActiveUntil);
    final removed2 = await _prefs.remove(_keyTrialItemId);
    
    return removed1 && removed2;
  }
  
  /// Get remaining trial time in hours
  /// 
  /// Returns 0 if no active trial
  int getRemainingTrialHours() {
    final activeUntil = getTrialActiveUntil();
    if (activeUntil == null) return 0;
    
    final now = DateTime.now();
    if (now.isAfter(activeUntil)) return 0;
    
    final difference = activeUntil.difference(now);
    return difference.inHours;
  }
  
  /// Get time until next trial ad can be shown
  /// 
  /// Returns Duration.zero if available now
  Duration getTimeUntilNextTrialAd() {
    if (canShowTrialOfferToday()) return Duration.zero;
    
    final lastShown = getLastTrialAdDate();
    if (lastShown == null) return Duration.zero;
    
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    return tomorrow.difference(now);
  }
  
  /// Get all trial state for debugging
  Map<String, dynamic> getTrialState() {
    return {
      'hasActiveTrial': hasActiveTrial(),
      'trialItemId': getTrialItemId(),
      'trialActiveUntil': getTrialActiveUntil()?.toIso8601String(),
      'lastTrialAdDate': getLastTrialAdDate()?.toIso8601String(),
      'remainingHours': getRemainingTrialHours(),
      'canShowOfferToday': canShowTrialOfferToday(),
    };
  }
}
