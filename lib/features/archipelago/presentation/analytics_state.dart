import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ChartType {
  timePerDay,
  sessionsPerDay,
  tagsPerDay,
}

// Controls which chart is visible
final selectedChartTypeProvider = StateProvider<ChartType>((ref) => ChartType.timePerDay);

// Controls which tag is selected for "TagPerDay" chart (null means none selected yet)
final selectedTagProvider = StateProvider<String?>((ref) => null);

// Controls the currently visible month in the analytics view
final currentMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});
