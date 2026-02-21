import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coin_service.dart';
import 'theme_unlock_service.dart';

/// CloudSyncService — Controlled cloud sync for Hybrid Migration.
///
/// Firestore document: `users/{uid}`
/// Fields: coins, themeMode, themeSeason, themeEnv, themeHouse,
///         accountInitialized, createdAt, lastSyncedAt
///
/// Sync strategy:
///   - NO auto-sync. Drawer is the sole orchestrator.
///   - On login: drawer calls fetch → shows dialog → applies on confirm.
///   - On coin change: push to cloud if logged in (guarded).
class CloudSyncService {
  CloudSyncService._();
  static final CloudSyncService _instance = CloudSyncService._();
  factory CloudSyncService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Guard flag: prevents pushCoinsIfLoggedIn from firing
  /// while applyCloudToLocal is updating local state.
  bool _isApplyingCloudData = false;

  /// Reference to the current user's document.
  DocumentReference? _userDoc(User? user) {
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid);
  }

  // ── SharedPreferences keys we sync ──────────────────────────
  static const _syncKeys = {
    'coins': 'island_coins',
    'themeMode': 'theme_mode',
    'themeSeason': 'theme_season',
    'themeEnv': 'theme_env',
    'themeHouse': 'theme_house',
  };

  // ── Fetch: read cloud coins (pure read, no side effects) ────

  /// Returns cloud coin balance, or null if no doc exists.
  /// Errors are caught and treated as null (safe fallback to Case B).
  Future<int?> fetchCloudCoins(User user) async {
    try {
      final doc = _userDoc(user);
      if (doc == null) return null;

      final snapshot = await doc.get();
      debugPrint('[CloudSync] fetchCloudCoins — exists: ${snapshot.exists}');

      if (!snapshot.exists) return null;

      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('coins')) return null;

      final coins = (data['coins'] as num).toInt();
      debugPrint('[CloudSync] fetchCloudCoins — cloudCoins: $coins');
      return coins;
    } catch (e) {
      debugPrint('[CloudSync] fetchCloudCoins error: $e');
      return null; // Treat as no cloud doc
    }
  }

  // ── Apply: cloud → local (cloud wins) ───────────────────────

  /// Downloads cloud data and overwrites local state.
  /// Uses setCoinsFromCloud() to avoid triggering pushCoinsIfLoggedIn.
  Future<void> applyCloudToLocal(User user) async {
    _isApplyingCloudData = true;
    try {
      final doc = _userDoc(user);
      if (doc == null) return;

      final snapshot = await doc.get();
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return;

      // Apply coins
      if (data.containsKey('coins')) {
        final cloudCoins = (data['coins'] as num).toInt();
        await CoinService().setCoinsFromCloud(cloudCoins);
        debugPrint('[CloudSync] applyCloudToLocal — coins: $cloudCoins');
      }

      // Apply theme data
      final prefs = await SharedPreferences.getInstance();
      for (final entry in _syncKeys.entries) {
        if (entry.key == 'coins') continue; // already handled
        if (data.containsKey(entry.key)) {
          final value = (data[entry.key] as num).toInt();
          await prefs.setInt(entry.value, value);
        }
      }

      // Apply unlocked themes
      if (data.containsKey('unlockedThemes')) {
        final ids = List<String>.from(data['unlockedThemes'] as List? ?? []);
        await ThemeUnlockService().setUnlockedFromCloud(ids);
        debugPrint('[CloudSync] applyCloudToLocal — unlockedThemes: $ids');
      }
    } finally {
      _isApplyingCloudData = false;
    }
  }

  // ── Upload: local → cloud (first login) ─────────────────────

  /// Uploads local coins + themes to Firestore. Creates the cloud doc.
  /// Sets accountInitialized, createdAt, lastSyncedAt.
  Future<void> uploadLocalToCloud(User user, int coins) async {
    try {
      final doc = _userDoc(user);
      if (doc == null) return;

      final prefs = await SharedPreferences.getInstance();
      final payload = <String, dynamic>{
        'coins': coins,
        'accountInitialized': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSyncedAt': FieldValue.serverTimestamp(),
      };

      // Include theme data
      for (final entry in _syncKeys.entries) {
        if (entry.key == 'coins') continue; // already set above
        payload[entry.key] = prefs.getInt(entry.value) ?? 0;
      }

      // Include unlocked themes
      payload['unlockedThemes'] = ThemeUnlockService().getUnlockedIds();

      await doc.set(payload);
      debugPrint('[CloudSync] uploadLocalToCloud — coins: $coins');
    } catch (e) {
      debugPrint('[CloudSync] uploadLocalToCloud error: $e');
      rethrow; // Let caller (drawer) handle — will signOut on failure
    }
  }

  // ── Real-time push (guarded) ────────────────────────────────

  /// Push coin balance to Firestore (if user is logged in).
  /// Called from CoinService.setCoins() for real-time sync.
  /// Skipped if cloud data is currently being applied (guard flag).
  Future<void> pushCoinsIfLoggedIn([int? coins]) async {
    // Guard: don't push while applying cloud data
    if (_isApplyingCloudData) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = _userDoc(user);
      if (doc == null) return;

      final coinValue = coins ?? CoinService().coinNotifier.value;
      await doc.set({
        'coins': coinValue,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Fail silently — local is still the primary store
      debugPrint('[CloudSync] pushCoins error: $e');
    }
  }
}
