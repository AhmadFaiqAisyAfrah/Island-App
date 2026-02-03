import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../shop/presentation/shop_screen.dart';
import '../../../../services/auth_service.dart';

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
                    MaterialPageRoute(builder: (_) => const ShopScreen())
                  );
                },
              ),
              const Spacer(),
              const _AuthSection(),
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
      title: Text("Select Theme", style: AppTextStyles.heading.copyWith(fontSize: 20)),
      content: SingleChildScrollView( // Safety
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SEASONAL (Island)
            Text("Seasonal", style: AppTextStyles.body.copyWith(fontSize: 14, color: AppColors.textSub)),
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
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: AppColors.textSub, height: 1),
            ),
            
            // ENVIRONMENT (World)
            Text("Environment", style: AppTextStyles.body.copyWith(fontSize: 14, color: AppColors.textSub)),
            const SizedBox(height: 8),
            _ThemeOption(
              label: "Default Sky",
              isSelected: state.environment == AppEnvironment.defaultSky,
              onTap: () => ref.read(themeProvider.notifier).setEnvironment(AppEnvironment.defaultSky),
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              label: "Mountain Horizon",
              isSelected: state.environment == AppEnvironment.mountain,
              onTap: () => ref.read(themeProvider.notifier).setEnvironment(AppEnvironment.mountain),
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              label: "Beach Breeze",
              isSelected: state.environment == AppEnvironment.beach,
              onTap: () => ref.read(themeProvider.notifier).setEnvironment(AppEnvironment.beach),
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              label: "Forest Fog",
              isSelected: state.environment == AppEnvironment.forest,
              onTap: () => ref.read(themeProvider.notifier).setEnvironment(AppEnvironment.forest),
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              label: "Space Night",
              isSelected: state.environment == AppEnvironment.space,
              onTap: () => ref.read(themeProvider.notifier).setEnvironment(AppEnvironment.space),
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

class _AuthSection extends ConsumerWidget {
  const _AuthSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Signed in as",
                style: AppTextStyles.body.copyWith(color: AppColors.textSub, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? "User",
                style: AppTextStyles.subHeading.copyWith(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                   await ref.read(authServiceProvider).signOut();
                },
                child: Text(
                  "Sign out", 
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMain, 
                    decoration: TextDecoration.underline,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          );
        }
        return const _GoogleSignInButton();
      },
      loading: () => const SizedBox(height: 20),
      error: (_, __) => const _GoogleSignInButton(),
    );
  }
}

class _GoogleSignInButton extends ConsumerWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Save your progress",
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSub,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.white.withOpacity(0.9),
          elevation: 0, 
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: () async {
              await ref.read(authServiceProvider).signInWithGoogle();
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textSub.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Minimal G logo representation
                  Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue, 
                    ),
                    alignment: Alignment.center,
                    child: const Text("G", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Continue with Google",
                    style: AppTextStyles.subHeading.copyWith(
                      color: AppColors.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
