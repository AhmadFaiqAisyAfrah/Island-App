import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'coin_service.dart';

/// ThemeUnlockService — Manages unlocked theme state (local + cloud).
///
/// Uses SharedPreferences.setStringList for local persistence.
/// Pushes unlockedThemes array to Firestore users/{uid} doc on unlock.
/// 
/// Default themes are always unlocked (handled at call site via isDefault).
/// This service only tracks non-default theme unlocks.
class ThemeUnlockService {
  static const _storageKey = 'unlocked_themes';

  ThemeUnlockService._();
  static final ThemeUnlockService _instance = ThemeUnlockService._();
  factory ThemeUnlockService() => _instance;

  SharedPreferences? _prefs;
  final Set<String> _unlockedIds = {};
  bool _initialized = false;

  /// Initialize: load unlocked IDs from SharedPreferences.
  /// Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await _preferences;
    final ids = prefs.getStringList(_storageKey) ?? [];
    _unlockedIds.addAll(ids);
    _initialized = true;
    debugPrint('[ThemeUnlock] init() — unlocked: $_unlockedIds');
  }

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Check if a theme ID is unlocked.
  bool isUnlocked(String themeId) => _unlockedIds.contains(themeId);

  /// Get current unlocked IDs (for cloud upload).
  List<String> getUnlockedIds() => _unlockedIds.toList();

  /// Unlock a theme: deduct coins, persist locally, push to cloud.
  /// Returns true if successful, false if insufficient coins.
  Future<bool> unlockTheme(String themeId, int price) async {
    // Safe coin deduction (CoinService prevents negative balance)
    final success = await CoinService().deductCoins(price);
    if (!success) return false;

    // Add to local set
    _unlockedIds.add(themeId);

    // Persist locally
    final prefs = await _preferences;
    await prefs.setStringList(_storageKey, _unlockedIds.toList());

    // Push to cloud (non-blocking)
    _pushUnlockedToCloud();

    debugPrint('[ThemeUnlock] unlockTheme($themeId) — price: $price, success');
    return true;
  }

  /// Set unlocked themes from cloud data (CASE A: cloud wins).
  /// Does NOT deduct coins or push back to cloud.
  Future<void> setUnlockedFromCloud(List<String> ids) async {
    _unlockedIds.clear();
    _unlockedIds.addAll(ids);
    final prefs = await _preferences;
    await prefs.setStringList(_storageKey, _unlockedIds.toList());
    debugPrint('[ThemeUnlock] setUnlockedFromCloud — ids: $ids');
  }

  /// Reset to guest mode: clear unlocked themes locally.
  /// Does NOT touch Firestore.
  Future<void> resetToGuest() async {
    _unlockedIds.clear();
    final prefs = await _preferences;
    await prefs.remove(_storageKey);
    debugPrint('[ThemeUnlock] resetToGuest()');
  }

  /// Push unlocked themes list to Firestore (if logged in).
  Future<void> _pushUnlockedToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'unlockedThemes': _unlockedIds.toList(),
        'lastSyncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[ThemeUnlock] pushToCloud error: $e');
    }
  }
}
