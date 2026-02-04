import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/features/archipelago/domain/analytics_model.dart';
import '../../../../core/theme/app_theme.dart';
import 'analytics_state.dart';
import '../../../../core/theme/theme_provider.dart';

class MonthlyVisualsPanel extends ConsumerWidget {
  final MonthlyStats stats;
  final DateTime monthDate;

  const MonthlyVisualsPanel({
    super.key, 
    required this.stats,
    required this.monthDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch State
    final chartType = ref.watch(selectedChartTypeProvider);
    final selectedTag = ref.watch(selectedTagProvider);

    // Only "Day" styling is used for Archipelago consistency.
    const labelColor = Colors.black54;
    
    // Select Data Source
    List<DailyPoint> chartData;
    String yAxisLabel = "m"; // "m" or "S"
    
    switch (chartType) {
      case ChartType.timePerDay:
        chartData = stats.dailyTimeline;
        yAxisLabel = "m";
        break;
      case ChartType.sessionsPerDay:
        chartData = stats.dailySessions;
        yAxisLabel = " sess";
        break;
      case ChartType.tagsPerDay:
        if (selectedTag != null && stats.tagTimelines.containsKey(selectedTag)) {
          chartData = stats.tagTimelines[selectedTag]!;
        } else {
          // Flatten empty if no tag selected or data missing
          chartData = []; 
        }
        yAxisLabel = "m";
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            child: Divider(color: Colors.black12, thickness: 1),
          ),
          
          // 1. CHART HEADER (Controls)
          _ChartControls(
            currentType: chartType,
            availableTags: stats.tagTimelines.keys.toList(),
            selectedTag: selectedTag,
            onTypeChanged: (type) {
               ref.read(selectedChartTypeProvider.notifier).state = type;
               // Reset tag if switching away from tag chart
               if (type != ChartType.tagsPerDay) {
                 ref.read(selectedTagProvider.notifier).state = null;
               } else {
                 // Auto-select first tag if available
                 if (stats.tagTimelines.isNotEmpty) {
                    ref.read(selectedTagProvider.notifier).state = stats.tagTimelines.keys.first;
                 }
               }
            },
            onTagChanged: (tag) {
              ref.read(selectedTagProvider.notifier).state = tag;
            },
          ),
          
          const SizedBox(height: 16),
          
          // 2. TIMELINE Chart
          SizedBox(
            height: 150,
            child: _FocusTimelineChart(
              dailyData: chartData,
              monthDate: monthDate,
              unitSuffix: yAxisLabel,
              lineColor: chartType == ChartType.sessionsPerDay ? AppColors.oceanDeep : AppColors.islandGrass,
            ),
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            child: Divider(color: Colors.black12, thickness: 1),
          ),

          // 2. TAGS Chart
           Text("Distribution", style: AppTextStyles.subHeading.copyWith(color: labelColor, fontSize: 14), textAlign: TextAlign.center),
           const SizedBox(height: 16),
           _TagDistributionChart(tagStats: stats.tagDistribution),
        ],
      ),
    );
  }
}

class _FocusTimelineChart extends StatelessWidget {
  final List<DailyPoint> dailyData;
  final DateTime monthDate;
  final String unitSuffix;
  final Color lineColor;

  const _FocusTimelineChart({
    required this.dailyData,
    required this.monthDate,
    this.unitSuffix = "m",
    this.lineColor = AppColors.islandGrass,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) return const Center(child: Text("No activity yet", style: TextStyle(color: Colors.black26)));

    // Find max for Y-axis scaling (add reasonable buffer)
    final maxVal = dailyData.fold<int>(0, (max, p) => p.minutes > max ? p.minutes : max);
    final maxY = maxVal > 0 ? (maxVal * 1.2) : 10.0; // At least small scale

    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final day = value.toInt();
                // Show label every 5 days
                if (day > 0 && day % 5 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text("$day", style: const TextStyle(color: Colors.black38, fontSize: 10)),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 20,
              interval: 1,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
             tooltipBgColor: Colors.white, // Calm clean background
             tooltipRoundedRadius: 8,
             tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
             fitInsideHorizontally: true,
             fitInsideVertically: true,
             getTooltipItems: (touchedSpots) {
               return touchedSpots.map((spot) {
                 final day = spot.x.toInt();
                 final monthIndex = monthDate.month - 1;
                 final monthName = months[monthIndex];
                 final year = monthDate.year;

                 // e.g. "4 February 2026"
                 final dateStr = "$day $monthName $year"; 
                 
                 return LineTooltipItem(
                   "$dateStr\n",
                   const TextStyle(
                     color: Colors.black54, 
                     fontWeight: FontWeight.normal, 
                     fontSize: 12,
                   ),
                   children: [
                     TextSpan(
                       text: "${spot.y.toInt()}$unitSuffix",
                       style: const TextStyle(
                         color: Colors.black87,
                         fontWeight: FontWeight.w600,
                         fontSize: 14,
                         height: 1.5,
                       ),
                     ),
                   ],
                 );
               }).toList();
             }
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: dailyData.map((d) => FlSpot(d.day.toDouble(), d.minutes.toDouble())).toList(),
            isCurved: true,
            curveSmoothness: 0.35,
            color: lineColor, 
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) => spot.y > 0, // Only show dots for active days
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: lineColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.1), // Very subtle fill
            ),
          ),
        ],
      ),
    );
  }
}



class _TagDistributionChart extends StatelessWidget {
  final List<TagStat> tagStats;

  const _TagDistributionChart({required this.tagStats});

  @override
  Widget build(BuildContext context) {
    if (tagStats.isEmpty) {
       return const Padding(
         padding: EdgeInsets.all(24.0),
         child: Center(child: Text("No focus data yet.", style: TextStyle(color: Colors.black26))),
       );
    }
    
    // Soft Palette
    final colors = [
       const Color(0xFF81B29A), // Green
       const Color(0xFFE07A5F), // Red/Orange
       const Color(0xFFF2CC8F), // Yellow
       const Color(0xFF3D405B), // Navy
       const Color(0xFFA2D2FF), // Blue
    ];

    return Column(
      children: [
        SizedBox(
          height: 240, // Increased from 180
          child: PieChart(
            PieChartData(
              sectionsSpace: 4, // Slightly more breathing room
              centerSpaceRadius: 80, // Much larger hole (160px diameter)
              sections: List.generate(tagStats.length, (index) {
                final stat = tagStats[index];
                final color = colors[index % colors.length];
                return PieChartSectionData(
                  color: color,
                  value: stat.totalMinutes.toDouble(),
                  title: '', // No labels on chart
                  radius: 20, // Thicker ring (20px)
                  badgeWidget: Text(stat.emoji, style: const TextStyle(fontSize: 20)), // Larger emoji
                  badgePositionPercentageOffset: 1.6, // Push slightly further out
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // LEGEND
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(tagStats.length, (index) {
             final stat = tagStats[index];
             final color = colors[index % colors.length];
             return Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                 const SizedBox(width: 6),
                 Text(
                   "${stat.label} (${stat.totalMinutes}m)",
                   style: const TextStyle(fontSize: 12, color: Colors.black54),
                 ),
               ],
             );
          }),
        ),
      ],
    );
  }
}

// -- Chart Controls Widget --
class _ChartControls extends StatelessWidget {
  final ChartType currentType;
  final List<String> availableTags;
  final String? selectedTag;
  final ValueChanged<ChartType> onTypeChanged;
  final ValueChanged<String?> onTagChanged;

  const _ChartControls({
    required this.currentType,
    required this.availableTags,
    required this.selectedTag,
    required this.onTypeChanged,
    required this.onTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Main Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05), // Very subtle background
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ChartType>(
              value: currentType,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
              style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black87),
              items: const [
                DropdownMenuItem(value: ChartType.timePerDay, child: Text("Time per Day")),
                DropdownMenuItem(value: ChartType.sessionsPerDay, child: Text("Sessions per Day")),
                DropdownMenuItem(value: ChartType.tagsPerDay, child: Text("Tag History")),
              ],
              onChanged: (val) {
                if (val != null) onTypeChanged(val);
              },
            ),
          ),
        ),

        // Tag Selector (Visible only if Tag mode is active)
        if (currentType == ChartType.tagsPerDay)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.islandBeige.withOpacity(0.3), // Slightly nuanced
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedTag != null && availableTags.contains(selectedTag) ? selectedTag : null,
                isDense: true,
                hint: const Text("Select Tag", style: TextStyle(fontSize: 12)),
                icon: const Icon(Icons.tag, size: 14, color: Colors.black54),
                style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black87),
                items: availableTags.map((tag) {
                  final shortTag = tag.length > 15 ? "${tag.substring(0, 12)}..." : tag;
                  return DropdownMenuItem(
                    value: tag,
                    child: Text(shortTag, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) onTagChanged(val);
                },
              ),
            ),
          ),
      ],
    );
  }
}
