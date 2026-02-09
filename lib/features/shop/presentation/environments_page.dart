import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/point_service.dart';
import '../../../../services/trial_service.dart';
import '../../../../core/data/shared_preferences_provider.dart';
import '../data/theme_catalog.dart';
import '../../../domain/monetization/monetization.dart';

class EnvironmentsPage extends ConsumerWidget {
  const EnvironmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final pointService = PointService(prefs);
    final trialService = TrialService(prefs);
    final currentPoints = pointService.getCurrentPoints();
    final canShowTrial = trialService.canShowTrialOfferToday();

    return Scaffold(
      backgroundColor: AppColors.skyBottom,
      appBar: AppBar(
        title: Text("Environments", style: AppTextStyles.heading.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ThemeCatalog.environments.map((item) => _ThemeItemCard(
            item: item,
            currentPoints: currentPoints,
            canShowTrial: canShowTrial,
            isTrialActive: trialService.isTrialActiveFor(item.id),
          )).toList(),
        ),
      ),
    );
  }
}

class _ThemeItemCard extends StatelessWidget {
  final MonetizableThemeItem item;
  final int currentPoints;
  final bool canShowTrial;
  final bool isTrialActive;

  const _ThemeItemCard({
    required this.item,
    required this.currentPoints,
    required this.canShowTrial,
    required this.isTrialActive,
  });

  @override
  Widget build(BuildContext context) {
    final bool canAfford = item.pointCost != null && currentPoints >= item.pointCost!;
    final bool showTrialButton = item.supportsTrial && canShowTrial && !isTrialActive;
    final bool isLocked = item.accessType != ItemAccessType.free;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: isLocked 
            ? Border.all(color: Colors.grey.withOpacity(0.3))
            : Border.all(color: item.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: item.accentColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isLocked 
                ? Icon(Icons.lock, color: Colors.grey.withOpacity(0.6), size: 28)
                : Icon(Icons.check_circle, color: AppColors.islandGrass, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.subHeading.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey : AppColors.textMain,
                        ),
                      ),
                    ),
                    if (isTrialActive)
                      _StatusBadge(
                        text: "ON TRIAL",
                        color: AppColors.islandGrass,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.textSub,
                  ),
                ),
                const SizedBox(height: 8),
                
                if (item.accessType == ItemAccessType.free)
                  _AccessLabel(icon: Icons.check, text: "Free", color: AppColors.islandGrass)
                else if (item.accessType == ItemAccessType.pointUnlock && item.pointCost != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: canAfford
                          ? const Color(0xFFFFD700).withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: canAfford
                            ? const Color(0xFFFFD700).withOpacity(0.5)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${item.pointCost}',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: canAfford ? const Color(0xFFFFA500) : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "coins",
                          style: AppTextStyles.body.copyWith(
                            fontSize: 11,
                            color: canAfford ? const Color(0xFFFFA500) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (item.accessType == ItemAccessType.premiumPurchase)
                  _AccessLabel(
                    icon: Icons.diamond,
                    text: "Premium",
                    color: Colors.purple,
                    isLocked: true,
                  )
                else if (item.accessType == ItemAccessType.trial)
                  _AccessLabel(
                    icon: Icons.timer,
                    text: "Try Free",
                    color: canShowTrial ? Colors.blue : Colors.grey,
                    isLocked: !canShowTrial,
                  ),
              ],
            ),
          ),

          if (isLocked) ...[
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.isPointUnlock)
                  _ActionButton(
                    label: "Unlock",
                    isEnabled: canAfford,
                    onPressed: canAfford ? () {} : null,
                  ),
                
                if (showTrialButton) ...[
                  if (item.isPointUnlock) const SizedBox(height: 8),
                  _ActionButton(
                    label: "Try",
                    isEnabled: true,
                    isSecondary: true,
                    onPressed: () {},
                  ),
                ],

                if (item.isPremium)
                  Text(
                    "Soon",
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AccessLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isLocked;

  const _AccessLabel({
    required this.icon,
    required this.text,
    required this.color,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.withOpacity(0.1) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isLocked ? Colors.grey : color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isLocked ? Colors.grey : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isEnabled;
  final bool isSecondary;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.isEnabled,
    this.isSecondary = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary 
              ? Colors.white 
              : (isEnabled ? AppColors.islandGrass : Colors.grey.withOpacity(0.3)),
          foregroundColor: isSecondary ? AppColors.islandGrass : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isSecondary 
                ? BorderSide(color: AppColors.islandGrass.withOpacity(0.3))
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isEnabled 
                ? (isSecondary ? AppColors.islandGrass : Colors.white)
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
