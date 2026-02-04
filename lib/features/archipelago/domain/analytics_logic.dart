import 'analytics_model.dart';
import 'daily_progress.dart';

class AnalyticsLogic {
  static MonthlyStats aggregateMonth(List<DailyProgress> history, DateTime month) {
    // Filter progress relevant to the target month
    final monthProgress = history.where((p) => 
      p.date.year == month.year && 
      p.date.month == month.month &&
      p.sessionCount > 0
    ).toList();

    if (monthProgress.isEmpty) {
      return const MonthlyStats();
    }

    int totalSeconds = 0;
    int totalSessions = 0;
    int activeDays = 0;

    for (final day in monthProgress) {
      totalSeconds += day.totalFocusSeconds;
      totalSessions += day.sessionCount;
      if (day.totalFocusSeconds > 0) {
        activeDays++;
      }
    }

    final totalMinutes = totalSeconds ~/ 60;
    final avgDailyMinutes = activeDays > 0 ? totalMinutes ~/ activeDays : 0;

    // --- Visual Stats Calculation ---
    
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final timelineData = <DailyPoint>[];
    final sessionData = <DailyPoint>[];
    
    // -- Data Normalization --
    // Create a normalized map of day -> tagMinutes to handle legacy data consistently
    // Map<DayInt, Map<TagKey, Minutes>>
    final normalizedData = <int, Map<String, int>>{};

    // First pass: Normalization & Keys collection
    final allTags = <String>{};
    
    for (final p in monthProgress) {
       Map<String, int> dailyTagMins = {};
       
       if (p.tagMinutes.isNotEmpty) {
         dailyTagMins = Map.from(p.tagMinutes);
       } else if (p.tags.isNotEmpty && p.totalFocusSeconds > 0) {
         // Legacy Backfill: Split evenly
         final totalMins = p.totalFocusSeconds ~/ 60;
         final minsPerTag = totalMins ~/ p.tags.length;
         for (final t in p.tags) {
           dailyTagMins["${t.emoji} ${t.label}"] = minsPerTag;
         }
       } else if (p.tags.isEmpty && p.totalFocusSeconds > 0) {
          // Legacy Unlabeled
          dailyTagMins["🏳️ Ontology"] = p.totalFocusSeconds ~/ 60;
       }
       
       normalizedData[p.date.day] = dailyTagMins;
       allTags.addAll(dailyTagMins.keys);
    }

    // Initialize timelines
    final tagTimelineMap = <String, List<DailyPoint>>{};
    for (final t in allTags) {
      tagTimelineMap[t] = [];
    }

    for (int day = 1; day <= daysInMonth; day++) {
      // Find progress for this specific day
      final dayData = monthProgress.firstWhere(
        (p) => p.date.day == day,
        orElse: () => DailyProgress(date: DateTime(month.year, month.month, day)),
      );
      
      // 1. Minutes Timeline
      timelineData.add(DailyPoint(day, dayData.totalFocusSeconds ~/ 60));
      
      // 2. Sessions Timeline
      sessionData.add(DailyPoint(day, dayData.sessionCount));
      
      // 3. Tag Timelines (Using Normalized Data)
      final dailyTags = normalizedData[day] ?? {};
      
      for (final tagKey in allTags) {
        final minutes = dailyTags[tagKey] ?? 0;
        tagTimelineMap[tagKey]!.add(DailyPoint(day, minutes));
      }
    }

    // 4. Tag Distribution (Summary Pie Chart - Using Normalized Data)
    final tagMap = <String, TagStat>{};

    normalizedData.forEach((day, tags) {
      tags.forEach((key, mins) {
         final parts = key.split(" ");
         final emoji = parts.first;
         final label = parts.skip(1).join(" ");
         _addTagStat(tagMap, label, emoji, mins);
      });
    });

    final distribution = tagMap.values.toList()
      ..sort((a, b) => b.totalMinutes.compareTo(a.totalMinutes));

    return MonthlyStats(
      totalFocusMinutes: totalMinutes,
      totalSessions: totalSessions,
      activeDays: activeDays,
      averageDailyMinutes: avgDailyMinutes,
      dailyTimeline: timelineData,
      dailySessions: sessionData, // NEW
      tagTimelines: tagTimelineMap, // NEW
      tagDistribution: distribution,
    );
  }

  static void _addTagStat(Map<String, TagStat> map, String label, String emoji, int mins) {
    final key = "$emoji $label";
    if (map.containsKey(key)) {
      final existing = map[key]!;
      map[key] = TagStat(label, emoji, existing.totalMinutes + mins);
    } else {
      map[key] = TagStat(label, emoji, mins);
    }
  }
}
