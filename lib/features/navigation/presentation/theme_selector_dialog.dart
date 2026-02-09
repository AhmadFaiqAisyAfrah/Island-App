import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/data/feature_discovery_provider.dart';
import '../../../../core/widgets/glass_hint.dart';
import 'theme_seasonal_page.dart';
import 'theme_environment_page.dart';
import 'theme_house_page.dart';

/// Theme Selector Dialog - Phase 2.5 Stabilization
/// 
/// Uses ThemeCatalog as SINGLE source of truth
/// No duplicated data, no hardcoded sections
class ThemeSelectorDialog extends ConsumerStatefulWidget {
  const ThemeSelectorDialog({super.key});

  @override
  ConsumerState<ThemeSelectorDialog> createState() => _ThemeSelectorDialogState();
}

class _ThemeSelectorDialogState extends ConsumerState<ThemeSelectorDialog> {
  bool _showThemeHint = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final discovery = ref.read(featureDiscoveryProvider);
      if (!discovery.hasSeenThemeHint) {
        setState(() => _showThemeHint = true);
        ref.read(featureDiscoveryProvider.notifier).markThemeHintSeen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.skyBottom,
      contentPadding: const EdgeInsets.all(24),
      title: Text("Select Theme", style: AppTextStyles.heading.copyWith(fontSize: 24)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showThemeHint) ...[
              GlassHint(
                text: 'Choose a place that feels right.',
                onDismiss: () => setState(() => _showThemeHint = false),
              ),
              const SizedBox(height: 16),
            ],
            
            _NavigationCard(
              title: "Seasonal",
              icon: Icons.calendar_today,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThemeSeasonalPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            _NavigationCard(
              title: "Environment",
              icon: Icons.landscape,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThemeEnvironmentPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            _NavigationCard(
              title: "House",
              icon: Icons.home,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThemeHousePage()),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Done", style: AppTextStyles.subHeading.copyWith(fontSize: 16)),
        )
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.islandGrass.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.islandGrass,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.subHeading.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSub,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
