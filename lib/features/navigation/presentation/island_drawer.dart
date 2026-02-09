import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../archipelago/presentation/archipelago_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../../services/auth_service.dart';
import '../../shop/presentation/shop_screen.dart';
import 'theme_selector_dialog.dart';

class IslandDrawer extends ConsumerWidget {
  const IslandDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                label: "Journal",
                isActive: false, 
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const ArchipelagoScreen())
                  );
                },
              ),
              _DrawerItem(
                label: "Themes",
                isActive: false,
                onTap: () {
                  Navigator.pop(context);
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
              _DrawerItem(
                label: "Settings",
                isActive: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: AppTextStyles.subHeading.copyWith(
          fontSize: 18,
          color: isActive ? AppColors.islandGrass : AppColors.textMain,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _AuthSection extends ConsumerWidget {
  const _AuthSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authService = ref.read(authServiceProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return _buildSignInButton(context, authService);
        }
        return _buildUserInfo(context, authService, user);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _buildSignInButton(context, authService),
    );
  }

  Widget _buildSignInButton(BuildContext context, AuthService authService) {
    return ElevatedButton.icon(
      onPressed: () => authService.signInWithGoogle(),
      icon: const Icon(Icons.login, size: 18),
      label: Text("Sign In", style: AppTextStyles.body.copyWith(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.islandGrass.withOpacity(0.2),
        foregroundColor: AppColors.textMain,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, AuthService authService, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.photoURL != null)
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(user.photoURL!),
          )
        else
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.islandGrass.withOpacity(0.3),
            child: Text(
              user.displayName?.substring(0, 1).toUpperCase() ?? "U",
              style: AppTextStyles.subHeading.copyWith(fontSize: 16),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          user.displayName ?? "User",
          style: AppTextStyles.body.copyWith(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        TextButton(
          onPressed: () => authService.signOut(),
          child: Text(
            "Sign Out",
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: AppColors.textSub,
            ),
          ),
        ),
      ],
    );
  }
}
