import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../domain/daily_progress.dart';

class ArchipelagoTile extends StatelessWidget {
  final DateTime? date;
  final DailyProgress? progress;
  final ThemeState themeState;
  final VoidCallback? onTap;

  const ArchipelagoTile({
    super.key,
    required this.date,
    this.progress,
    required this.themeState,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox.shrink();

    final isDay = themeState.mode == AppThemeMode.day;
    final hasHouse = progress != null && progress!.sessionCount > 0;
    
    // Aesthetic: 
    // If house -> Show House Emoji + Date
    // If no house -> Show Date (faded)
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: hasHouse 
            ? (isDay ? Colors.white60 : Colors.white10)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasHouse)
              const Text("🏡", style: TextStyle(fontSize: 24)),
            
            const SizedBox(height: 4),
            
            Text(
              "${date!.day}",
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: hasHouse
                  ? (isDay ? Colors.black87 : Colors.white)
                  : (isDay ? Colors.black54 : Colors.white54), // Increased contrast
                fontWeight: hasHouse ? FontWeight.w600 : FontWeight.w500, // Medium weight for better readability
              ),
            ),
          ],
        ),
      ),
    );
  }
}
