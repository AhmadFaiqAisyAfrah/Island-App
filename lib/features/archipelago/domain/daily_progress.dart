import 'dart:convert';

class DailyProgress {
  final DateTime date;
  final int totalFocusSeconds;
  final int sessionCount;
  final List<ArchipelagoTag> tags;
  final Map<String, int> tagMinutes; // Key: "emoji label"

  const DailyProgress({
    required this.date,
    this.totalFocusSeconds = 0,
    this.sessionCount = 0,
    this.tags = const [],
    this.tagMinutes = const {},
  });

  // Calculate House Level (0-3)
  int get houseLevel {
    if (sessionCount == 0) return 0; // Empty land
    if (sessionCount <= 2) return 1; // Small house
    if (sessionCount <= 4) return 2; // House + Tree
    return 3; // House + Garden
  }

  DailyProgress copyWith({
    int? totalFocusSeconds,
    int? sessionCount,
    List<ArchipelagoTag>? tags,
    Map<String, int>? tagMinutes,
  }) {
    return DailyProgress(
      date: date,
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      sessionCount: sessionCount ?? this.sessionCount,
      tags: tags ?? this.tags,
      tagMinutes: tagMinutes ?? this.tagMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'totalFocusSeconds': totalFocusSeconds,
      'sessionCount': sessionCount,
      'tags': tags.map((x) => x.toMap()).toList(),
      'tagMinutes': tagMinutes,
    };
  }

  factory DailyProgress.fromMap(Map<String, dynamic> map) {
    return DailyProgress(
      date: DateTime.parse(map['date']),
      totalFocusSeconds: map['totalFocusSeconds']?.toInt() ?? 0,
      sessionCount: map['sessionCount']?.toInt() ?? 0,
      tags: List<ArchipelagoTag>.from(
        (map['tags'] as List? ?? []).map((x) => ArchipelagoTag.fromMap(x)),
      ),
      tagMinutes: Map<String, int>.from(map['tagMinutes'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory DailyProgress.fromJson(String source) => DailyProgress.fromMap(json.decode(source));
}

// Simplified Tag for storage
class ArchipelagoTag {
  final String label;
  final String emoji;

  const ArchipelagoTag({
    required this.label,
    required this.emoji,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'emoji': emoji,
    };
  }

  factory ArchipelagoTag.fromMap(Map<String, dynamic> map) {
    return ArchipelagoTag(
      label: map['label'] ?? '',
      emoji: map['emoji'] ?? '',
    );
  }
}
