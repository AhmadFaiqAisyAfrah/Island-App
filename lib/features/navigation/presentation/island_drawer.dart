import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';

class IslandDrawer extends ConsumerWidget {
  const IslandDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    
    return Drawer(
      backgroundColor: AppColors.skyBottom, 
      elevation: 0, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text("Island", style: AppTextStyles.heading.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              Text("Your quiet place.", style: AppTextStyles.body.copyWith(color: AppColors.textSub, fontSize: 14)),
              const SizedBox(height: 64),
              
              // Menu Items
              _DrawerItem(
                label: "Island",
                isActive: true,
                onTap: () => Navigator.pop(context), 
              ),
              _DrawerItem(
                label: "Themes",
                isActive: false, // Could highlight if currentTheme != day, but let's keep simple
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _showThemeSelector(context);
                },
              ),
              _DrawerItem(
                label: "Shop",
                isActive: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: "Shop"))
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const ThemeSelectorDialog(),
    );
  }
}

class ThemeSelectorDialog extends ConsumerWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeProvider);
    
    return AlertDialog(
      backgroundColor: AppColors.skyBottom,
      title: Text("Select Environment", style: AppTextStyles.heading.copyWith(fontSize: 20)),
      content: SingleChildScrollView( // Safety
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TIME OF DAY
            Text("Time", style: AppTextStyles.body.copyWith(fontSize: 14, color: AppColors.textSub)),
            const SizedBox(height: 8),
            _ThemeOption(
              label: "Day",
              isSelected: state.mode == AppThemeMode.day,
              onTap: () => ref.read(themeProvider.notifier).setMode(AppThemeMode.day),
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              label: "Night",
              isSelected: state.mode == AppThemeMode.night,
              onTap: () => ref.read(themeProvider.notifier).setMode(AppThemeMode.night),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: AppColors.textSub, height: 1),
            ),
            
            // SEASON
            Text("Season", style: AppTextStyles.body.copyWith(fontSize: 14, color: AppColors.textSub)),
            const SizedBox(height: 8),
            _ThemeOption(
              label: "Original",
              isSelected: state.season == AppSeason.normal,
              onTap: () => ref.read(themeProvider.notifier).setSeason(AppSeason.normal),
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              label: "Sakura",
              isSelected: state.season == AppSeason.sakura,
              onTap: () => ref.read(themeProvider.notifier).setSeason(AppSeason.sakura),
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              label: "Autumn",
              isSelected: state.season == AppSeason.autumn,
              onTap: () => ref.read(themeProvider.notifier).setSeason(AppSeason.autumn),
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              label: "Winter",
              isSelected: state.season == AppSeason.winter,
              onTap: () => ref.read(themeProvider.notifier).setSeason(AppSeason.winter),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _ThemeOption({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.islandGrass.withOpacity(0.2) : Colors.transparent,
      // borderRadius removed (conflict with shape)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
          ? const BorderSide(color: AppColors.islandGrass, width: 2) 
          : const BorderSide(color: Colors.transparent, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Text(label, style: AppTextStyles.subHeading.copyWith(color: AppColors.textMain)),
              const Spacer(),
              if (isSelected) 
                Icon(Icons.check_circle, color: AppColors.islandGrass, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: isActive 
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12)
              )
            : null,
          child: Text(
            label,
            style: AppTextStyles.subHeading.copyWith(
              color: isActive ? AppColors.textMain : AppColors.textMain.withOpacity(0.7),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textMain),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: AppTextStyles.heading),
            const SizedBox(height: 16),
            Text(
              "Coming soon.",
              style: AppTextStyles.body.copyWith(color: AppColors.textSub),
            ),
          ],
        ),
      ),
    );
  }
}
