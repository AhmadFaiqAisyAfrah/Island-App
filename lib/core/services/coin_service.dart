import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cloud_sync_service.dart';

/// CoinService — Single Source of Truth for Island Coins.
///
/// Uses SharedPreferences for persistence and ValueNotifier for reactive UI.
/// All coin reads/writes MUST go through this service.
/// Coin changes are pushed to Firestore via CloudSyncService (if logged in).
class CoinService {
  static const _coinsKey = 'island_coins';

  // Legacy key from PointService — used for one-time data migration
  static const _legacyPointsKey = 'total_points';

  CoinService._();
  static final CoinService _instance = CoinService._();
  factory CoinService() => _instance;

  SharedPreferences? _prefs;

  /// Reactive coin balance. UI widgets should use ValueListenableBuilder
  /// to listen to this and automatically rebuild on changes.
  final ValueNotifier<int> coinNotifier = ValueNotifier<int>(0);

  bool _initialized = false;

  /// Initialize the service. Call once at app startup.
  /// Loads persisted balance into [coinNotifier] and runs data migration.
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await _preferences;

    // ── Data Migration: merge legacy 'total_points' → 'island_coins' ──
    final legacyPoints = prefs.getInt(_legacyPointsKey) ?? 0;
    final currentCoins = prefs.getInt(_coinsKey) ?? 0;

    if (legacyPoints > 0) {
      // Take the higher value so the user never loses progress
      final merged = legacyPoints > currentCoins ? legacyPoints : currentCoins;
      await prefs.setInt(_coinsKey, merged);
      await prefs.remove(_legacyPointsKey);
      coinNotifier.value = merged;
      debugPrint('[CoinService] Migrated legacy points ($legacyPoints) → coins ($merged)');
    } else {
      coinNotifier.value = currentCoins;
    }

    _initialized = true;
    debugPrint('[CoinService] init() complete — coins: ${coinNotifier.value}');
  }

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get current coin balance (async, reads from disk).
  Future<int> getCoins() async {
    final prefs = await _preferences;
    return prefs.getInt(_coinsKey) ?? 0;
  }

  /// Add coins to current balance. Returns new total.
  /// Also updates [coinNotifier] for reactive UI.
  Future<int> addCoins(int amount) async {
    final current = await getCoins();
    final newTotal = current + amount;
    await setCoins(newTotal);
    return newTotal;
  }

  /// Deduct coins from current balance. Returns true if successful.
  /// Returns false if insufficient balance.
  Future<bool> deductCoins(int amount) async {
    final current = await getCoins();
    if (current < amount) return false;
    await setCoins(current - amount);
    return true;
  }

  /// Set coin balance to an exact value.
  /// Also updates [coinNotifier] for reactive UI and pushes to cloud.
  Future<void> setCoins(int value) async {
    final prefs = await _preferences;
    await prefs.setInt(_coinsKey, value);
    coinNotifier.value = value;

    // Push to cloud (non-blocking, fails silently if not logged in)
    CloudSyncService().pushCoinsIfLoggedIn(value);
  }

  // ── Controlled methods (no cloud push) ─────────────────────

  /// Set coins from cloud data. Does NOT push back to cloud.
  /// Used by CloudSyncService.applyCloudToLocal() to avoid infinite loop.
  Future<void> setCoinsFromCloud(int value) async {
    debugPrint('[CoinService] setCoinsFromCloud($value)');
    final prefs = await _preferences;
    await prefs.setInt(_coinsKey, value);
    coinNotifier.value = value;
  }

  /// Reset to guest mode (0 coins). Called after logout confirmation.
  /// Does NOT push to cloud (user is already signed out).
  Future<void> resetToGuest() async {
    debugPrint('[CoinService] resetToGuest() — coins → 0');
    final prefs = await _preferences;
    await prefs.setInt(_coinsKey, 0);
    coinNotifier.value = 0;
  }
}
