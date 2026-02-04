import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../data/archipelago_provider.dart';
import '../domain/daily_progress.dart';
import '../domain/calendar_logic.dart'; // Logic import
import 'archipelago_tile.dart';
import '../domain/analytics_logic.dart';
import 'monthly_stats_panel.dart';
import 'monthly_visuals_panel.dart';
import 'analytics_state.dart';

class ArchipelagoScreen extends ConsumerStatefulWidget {
  const ArchipelagoScreen({super.key});

  @override
  ConsumerState<ArchipelagoScreen> createState() => _ArchipelagoScreenState();
}

class _ArchipelagoScreenState extends ConsumerState<ArchipelagoScreen> {
  // Navigation state is now managed by providers.

  @override
  void initState() {
    super.initState();
  }

  DailyProgress? _getProgressForDate(List<DailyProgress> history, DateTime date) {
    try {
      return history.firstWhere((p) => 
        p.date.year == date.year && 
        p.date.month == date.month && 
        p.date.day == date.day
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeStateRaw = ref.watch(themeProvider);
    final history = ref.watch(archipelagoProvider);
    final visibleMonth = ref.watch(currentMonthProvider);
    
    // Force Day Mode for Archipelago (Journal)
    const isDay = true; 
    final themeState = themeStateRaw.copyWith(mode: AppThemeMode.day);
    final bgColor = isDay ? const Color(0xFFF0F4F8) : const Color(0xFF1A1A1A);
    final monthName = _getMonthName(visibleMonth.month);

    final stats = AnalyticsLogic.aggregateMonth(history, visibleMonth);
    final days = CalendarLogic.generateMonthGrid(visibleMonth);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDay ? Colors.black87 : Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Previous Month Button
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 28, color: Colors.black54),
              onPressed: () {
                final newMonth = DateTime(visibleMonth.year, visibleMonth.month - 1);
                ref.read(currentMonthProvider.notifier).state = newMonth;
              },
            ),
            
            // Month Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "$monthName ${visibleMonth.year}",
                style: AppTextStyles.heading.copyWith(
                  color: isDay ? Colors.black87 : Colors.white,
                  fontSize: 18, // Slightly calmer size
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Next Month Button
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 28, color: Colors.black54),
              onPressed: () {
                final newMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
                ref.read(currentMonthProvider.notifier).state = newMonth;
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: SingleChildScrollView(
          key: ValueKey(visibleMonth), // Triggers animation on change
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Weekday Headers (S M T W T F S)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ["S", "M", "T", "W", "T", "F", "S"].map((day) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 32) / 7, // Approximate width
                      child: Center(
                        child: Text(
                          day,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            color: Colors.black38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, 
                    childAspectRatio: 0.7, 
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: days.length,
                  itemBuilder: (context, idx) {
                    final date = days[idx];
                    if (date == null) return const SizedBox.shrink();

                    final progress = _getProgressForDate(history, date);

                    return ArchipelagoTile(
                      date: date,
                      progress: progress,
                      themeState: themeState, 
                      onTap: () {
                        if (progress != null) {
                          _showDetails(context, progress, isDay);
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Analytics Section
              MonthlyStatsPanel(stats: stats),
              MonthlyVisualsPanel(
                stats: stats,
                monthDate: visibleMonth,
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June", 
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

  void _showDetails(BuildContext context, DailyProgress progress, bool isDay) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDay ? Colors.white : const Color(0xFF2C2C2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2)
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Text(
                    "${progress.date.day} ${_getMonthName(progress.date.month)} ${progress.date.year}",
                    style: AppTextStyles.heading.copyWith(fontSize: 24, color: isDay ? Colors.black : Colors.white),
                  ),
                  const Text("🏡", style: TextStyle(fontSize: 32)),
                ],
              ),
              const SizedBox(height: 16),
              
              _detailRow("Sessions", "${progress.sessionCount}", isDay),
              const SizedBox(height: 8),
              _detailRow("Focus Time", "${progress.totalFocusSeconds ~/ 60} min", isDay),
              
              const SizedBox(height: 24),
              Text("Intentions", style: AppTextStyles.subHeading.copyWith(fontSize: 14, color: isDay ? Colors.black54 : Colors.white54)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: progress.tags.map((tag) => Chip(
                  label: Text("${tag.emoji} ${tag.label}"),
                  backgroundColor: isDay ? AppColors.islandGrass.withOpacity(0.1) : Colors.white10,
                  labelStyle: TextStyle(color: isDay ? AppColors.textMain : Colors.white),
                )).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  Widget _detailRow(String label, String value, bool isDay) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(color: isDay ? Colors.black54 : Colors.white54)),
        Text(value, style: AppTextStyles.heading.copyWith(fontSize: 18, color: isDay ? Colors.black87 : Colors.white)),
      ],
    );
  }
}
