import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/daily_progress.dart';
import 'archipelago_repository.dart';

// Dependency Injection for Repository
// Dependency Injection for Repository
final archipelagoRepoProvider = Provider<ArchipelagoRepository>((ref) {
  // Return MVP-Safe Memory Repository by default
  // This prevents crashes if main.dart overrides fail (e.g. Hot Reload)
  return _InMemoryArchipelagoRepository();
});

// StateNotifier for the list of progress
class ArchipelagoNotifier extends StateNotifier<List<DailyProgress>> {
  final ArchipelagoRepository _repository;

  ArchipelagoNotifier(this._repository) : super([]) {
    _loadInitialData();
  }

  /// Guard: blocks notifier-triggered cloud push during history replacement.
  bool _isReplacingHistory = false;
  bool get isReplacingHistory => _isReplacingHistory;

  Future<void> _loadInitialData() async {
    final data = await _repository.loadHistory();
    // Sort by date descending (newest first) for UI
    data.sort((a, b) => b.date.compareTo(a.date));
    state = data;
  }

  /// Public re-read from SharedPreferences into Riverpod state.
  /// Called by drawer after cloud-to-local sync to rehydrate UI.
  /// Does NOT trigger pushEntryIfLoggedIn (no save/write, just state set).
  Future<void> reloadFromStorage() async {
    await _loadInitialData();
  }

  Future<void> addSession({
    required int durationSeconds,
    required String tagLabel,
    required String tagEmoji,
  }) async {
    await _repository.saveSession(
      durationSeconds: durationSeconds, 
      tagLabel: tagLabel, 
      tagEmoji: tagEmoji
    );
    // Reload state
    _loadInitialData(); 
  }

  /// Replaces local history with cloud data. Guarded.
  Future<void> replaceHistory(List<DailyProgress> entries) async {
    _isReplacingHistory = true;
    try {
      await _repository.replaceHistory(entries);
      entries.sort((a, b) => b.date.compareTo(a.date));
      state = entries;
    } finally {
      _isReplacingHistory = false;
    }
  }

  /// Clears local history (logout → guest reset).
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    state = [];
  }
}

final archipelagoProvider = StateNotifierProvider<ArchipelagoNotifier, List<DailyProgress>>((ref) {
  final repo = ref.watch(archipelagoRepoProvider);
  return ArchipelagoNotifier(repo);
});

// --- MVP Safe Implementation (In-Memory Fallback) ---
class _InMemoryArchipelagoRepository implements ArchipelagoRepository {
  final List<DailyProgress> _data = [];

  @override
  Future<List<DailyProgress>> loadHistory() async {
    return List.from(_data);
  }

  @override
  Future<void> clearHistory() async {
    _data.clear();
  }

  @override
  Future<void> replaceHistory(List<DailyProgress> entries) async {
    _data.clear();
    _data.addAll(entries);
  }

  @override
  Future<void> saveSession({required int durationSeconds, required String tagLabel, required String tagEmoji}) async {
    final today = DateTime.now();
    final index = _data.indexWhere((p) => 
      p.date.year == today.year && p.date.month == today.month && p.date.day == today.day
    );

    if (index != -1) {
      final existing = _data[index];
      final updatedTags = List<ArchipelagoTag>.from(existing.tags);
      if (!updatedTags.any((t) => t.label == tagLabel && t.emoji == tagEmoji)) {
        updatedTags.add(ArchipelagoTag(label: tagLabel, emoji: tagEmoji));
      }
      // Update Tag Minutes
      final Map<String, int> updatedTagMinutes = Map.from(existing.tagMinutes);
      final tagKey = "$tagEmoji $tagLabel";
      final int newMinutes = (durationSeconds / 60).ceil();
      updatedTagMinutes[tagKey] = (updatedTagMinutes[tagKey] ?? 0) + newMinutes;

      _data[index] = existing.copyWith(
        totalFocusSeconds: existing.totalFocusSeconds + durationSeconds,
        sessionCount: existing.sessionCount + 1,
        tags: updatedTags,
        tagMinutes: updatedTagMinutes,
      );
    } else {
      final int minutes = (durationSeconds / 60).ceil();
      _data.add(DailyProgress(
        date: today,
        totalFocusSeconds: durationSeconds,
        sessionCount: 1,
        tags: [ArchipelagoTag(label: tagLabel, emoji: tagEmoji)],
        tagMinutes: {"$tagEmoji $tagLabel": minutes},
      ));
    }
  }
}
