import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class IslandDrawer extends StatelessWidget {
  const IslandDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.skyBottom, // Matches app background
      elevation: 0, // Flat
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
              Text(
                "Island",
                style: AppTextStyles.heading.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                "Your quiet place.",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSub,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 64),
              
              // Menu Items
              _DrawerItem(
                label: "Island",
                isActive: true,
                onTap: () => Navigator.pop(context), // Close drawer (already home)
              ),
              _DrawerItem(
                label: "Themes",
                isActive: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: "Themes"))
                  );
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
