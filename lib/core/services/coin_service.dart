import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CoinService — Single Source of Truth for Island Coins.
///
/// Uses SharedPreferences for persistence and ValueNotifier for reactive UI.
/// All coin reads/writes MUST go through this service.
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
  /// Also updates [coinNotifier] for reactive UI.
  Future<void> setCoins(int value) async {
    final prefs = await _preferences;
    await prefs.setInt(_coinsKey, value);
    coinNotifier.value = value;
  }
}

