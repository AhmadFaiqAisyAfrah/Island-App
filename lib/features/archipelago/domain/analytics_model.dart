class MonthlyStats {
  final int totalFocusMinutes;
  final int totalSessions;
  final int activeDays; 
  final int averageDailyMinutes; 
  final List<DailyPoint> dailyTimeline; // Focus Minutes
  final List<DailyPoint> dailySessions; // Session Count
  final Map<String, List<DailyPoint>> tagTimelines; // Per Tag Minutes
  final List<TagStat> tagDistribution;
  
  const MonthlyStats({
    this.totalFocusMinutes = 0,
    this.totalSessions = 0,
    this.activeDays = 0,
    this.averageDailyMinutes = 0,
    this.dailyTimeline = const [],
    this.dailySessions = const [],
    this.tagTimelines = const {},
    this.tagDistribution = const [],
  });

  String get formattedTotalTime {
    final hours = totalFocusMinutes ~/ 60;
    final mins = totalFocusMinutes % 60;
    if (hours > 0) {
      return "${hours}h ${mins}m";
    }
    return "${mins}m";
  }
}

class DailyPoint {
  final int day; // 1..31
  final int minutes;

  const DailyPoint(this.day, this.minutes);
}

class TagStat {
  final String label;
  final String emoji;
  final int totalMinutes;

  const TagStat(this.label, this.emoji, this.totalMinutes);
}
