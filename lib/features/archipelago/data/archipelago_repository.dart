import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/daily_progress.dart';

class ArchipelagoRepository {
  static const String _storageKey = 'archipelago_progress';
  final SharedPreferences _prefs;

  ArchipelagoRepository(this._prefs);

  Future<List<DailyProgress>> loadHistory() async {
    final String? jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((e) => DailyProgress.fromMap(e)).toList();
    } catch (e) {
      // Return empty on corruption
      return [];
    }
  }

  Future<void> saveSession({
    required int durationSeconds,
    required String tagLabel,
    required String tagEmoji,
  }) async {
    final history = await loadHistory();
    final today = DateTime.now();
    
    // Find today's entry (ignoring time)
    final index = history.indexWhere((p) => 
      p.date.year == today.year && 
      p.date.month == today.month && 
      p.date.day == today.day
    );

    List<DailyProgress> updatedHistory = List.from(history);
    DailyProgress todayProgress;

    if (index != -1) {
      // Update existing
      final existing = updatedHistory[index];
      
      // Update tags if new
      final List<ArchipelagoTag> updatedTags = List.from(existing.tags);
      final tagExists = updatedTags.any((t) => t.label == tagLabel && t.emoji == tagEmoji);
      if (!tagExists) {
        updatedTags.add(ArchipelagoTag(label: tagLabel, emoji: tagEmoji));
      }
      
      // Update Tag Minutes
      // Use ceil() to ensure at least 1 minute is credited for any completed session (even short ones)
      // This prevents "Empty Chart" confusion during testing or short bursts.
      final int newMinutes = (durationSeconds / 60).ceil();
      
      final Map<String, int> updatedTagMinutes = Map.from(existing.tagMinutes);
      final tagKey = "$tagEmoji $tagLabel";
      updatedTagMinutes[tagKey] = (updatedTagMinutes[tagKey] ?? 0) + newMinutes;

      todayProgress = existing.copyWith(
        totalFocusSeconds: existing.totalFocusSeconds + durationSeconds,
        sessionCount: existing.sessionCount + 1,
        tags: updatedTags,
        tagMinutes: updatedTagMinutes,
      );
      updatedHistory[index] = todayProgress;
    } else {
      // Create new
      final int minutes = (durationSeconds / 60).ceil();
      
      todayProgress = DailyProgress(
        date: today,
        totalFocusSeconds: durationSeconds,
        sessionCount: 1,
        tags: [ArchipelagoTag(label: tagLabel, emoji: tagEmoji)],
        tagMinutes: {"$tagEmoji $tagLabel": minutes},
      );
      // Add to FRONT or END? Usually descending for display, but storage can be any order.
      // Let's store chronological (append)
      updatedHistory.add(todayProgress);
    }

    // Persist
    final String encoded = json.encode(updatedHistory.map((e) => e.toMap()).toList());
    await _prefs.setString(_storageKey, encoded);
  }
}
