import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../features/archipelago/domain/daily_progress.dart';

/// JournalSyncService — Controlled cloud sync for journal (archipelago) data.
///
/// Firestore sub-collection: `users/{uid}/journal/{dateKey}`
///
/// Fully independent — does NOT call CloudSyncService or CoinService.
/// Drawer is the sole orchestrator.
class JournalSyncService {
  JournalSyncService._();
  static final JournalSyncService _instance = JournalSyncService._();
  factory JournalSyncService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _storageKey = 'archipelago_progress';

  /// Guard flag: prevents pushEntryIfLoggedIn from firing
  /// while applyCloudToLocal is updating local state.
  bool _isApplyingCloudJournal = false;

  /// Reference to journal sub-collection.
  CollectionReference? _journalCol(User? user) {
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('journal');
  }

  // ── Existence check (pure read, no side effects) ────────────

  /// Returns true if cloud has ≥1 journal entry. False on error.
  Future<bool> cloudJournalExists(User user) async {
    try {
      final col = _journalCol(user);
      if (col == null) return false;

      final snapshot = await col.limit(1).get();
      final exists = snapshot.docs.isNotEmpty;
      debugPrint('[JournalSync] cloudJournalExists — $exists');
      return exists;
    } catch (e) {
      debugPrint('[JournalSync] cloudJournalExists error: $e');
      return false;
    }
  }

  // ── Apply: cloud → local (cloud wins) ───────────────────────

  /// Downloads all cloud journal entries and overwrites local storage.
  /// Guarded by _isApplyingCloudJournal.
  Future<void> applyCloudToLocal(User user) async {
    _isApplyingCloudJournal = true;
    try {
      final col = _journalCol(user);
      if (col == null) return;

      final snapshot = await col.get();
      final entries = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DailyProgress.fromMap(data);
      }).toList();

      // Overwrite local SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(entries.map((e) => e.toMap()).toList());
      await prefs.setString(_storageKey, encoded);

      debugPrint('[JournalSync] applyCloudToLocal — ${entries.length} entries');
    } finally {
      _isApplyingCloudJournal = false;
    }
  }

  // ── Upload: local → cloud (first login) ─────────────────────

  /// Atomic batch: deletes all existing cloud docs, then writes all local
  /// entries. Single batch.commit(). Rethrows on failure for rollback.
  Future<void> uploadLocalToCloud(
    User user,
    List<DailyProgress> entries,
  ) async {
    try {
      final col = _journalCol(user);
      if (col == null) return;

      final batch = _firestore.batch();

      // 1. Delete all existing cloud docs (prevent merge)
      final existing = await col.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      // 2. Write all local entries
      for (final entry in entries) {
        final docId = entry.date.toIso8601String().substring(0, 10);
        batch.set(col.doc(docId), entry.toMap());
      }

      // 3. Atomic commit
      await batch.commit();

      debugPrint(
          '[JournalSync] uploadLocalToCloud — ${entries.length} entries');
    } catch (e) {
      debugPrint('[JournalSync] uploadLocalToCloud error: $e');
      rethrow; // Let drawer handle — will signOut on failure
    }
  }

  // ── Real-time push (guarded) ────────────────────────────────

  /// Push single entry to Firestore (if logged in).
  /// Skipped if cloud journal data is currently being applied.
  Future<void> pushEntryIfLoggedIn(DailyProgress entry) async {
    if (_isApplyingCloudJournal) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final col = _journalCol(user);
      if (col == null) return;

      final docId = entry.date.toIso8601String().substring(0, 10);
      await col.doc(docId).set(entry.toMap(), SetOptions(merge: true));
    } catch (e) {
      // Fail silently — local is still the primary store
      debugPrint('[JournalSync] pushEntry error: $e');
    }
  }

  // ── Guest reset ─────────────────────────────────────────────

  /// Clears local journal history. Does NOT touch Firestore.
  Future<void> resetToGuest() async {
    debugPrint('[JournalSync] resetToGuest() — clearing local journal');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
