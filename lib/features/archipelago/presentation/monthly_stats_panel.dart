import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../domain/analytics_model.dart';
import '../../../../core/theme/theme_provider.dart';

class MonthlyStatsPanel extends StatelessWidget {
  final MonthlyStats stats;

  const MonthlyStatsPanel({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // Only "Day" styling is used for Archipelago as desired by user.
    const textColor = Colors.black87;
    const labelColor = Colors.black54;
    const boxColor = Color(0x10000000); // Very subtle dark overlay on light bg

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _StatBox(
                    label: "Active Days",
                    value: "${stats.activeDays}",
                    textColor: textColor,
                    labelColor: labelColor,
                    bgColor: boxColor),
                const SizedBox(width: 8),
                _StatBox(
                    label: "Sessions",
                    value: "${stats.totalSessions}",
                    textColor: textColor,
                    labelColor: labelColor,
                    bgColor: boxColor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatBox(
                    label: "Total Focus",
                    value: stats.formattedTotalTime,
                    textColor: textColor,
                    labelColor: labelColor,
                    bgColor: boxColor),
                const SizedBox(width: 8),
                _StatBox(
                    label: "Avg / Active Day",
                    value: "${stats.averageDailyMinutes}m",
                    textColor: textColor,
                    labelColor: labelColor,
                    bgColor: boxColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color labelColor;
  final Color bgColor;

  const _StatBox({
    required this.label,
    required this.value,
    required this.textColor,
    required this.labelColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.heading.copyWith(
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: labelColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
