import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../archipelago/presentation/archipelago_screen.dart';
import '../../archipelago/data/archipelago_repository.dart';
import '../../archipelago/data/archipelago_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/services/coin_service.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../../../../core/services/journal_sync_service.dart';
import '../../../../core/services/theme_unlock_service.dart';
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
                emoji: '\ud83c\udfdd', // 🏝️
                isActive: true,
                onTap: () => Navigator.pop(context), 
              ),
              _DrawerItem(
                label: "Journal",
                emoji: '\ud83d\udcd3', // 📓
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
                emoji: '\ud83c\udfa8', // 🎨
                isActive: false,
                onTap: () {
                  Navigator.pop(context);
                  _showThemeSelector(context);
                },
              ),
              _DrawerItem(
                label: "Shop",
                emoji: '\ud83d\uded2', // 🛒
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
                emoji: '\u2699\ufe0f', // ⚙️
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
  final String emoji;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.emoji,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(
        emoji,
        style: const TextStyle(
          fontSize: 24,
        ),
      ),
      title: Text(
        label,
        style: AppTextStyles.subHeading.copyWith(
          fontSize: 18,
          color: isActive ? AppColors.islandGrass : AppColors.textMain,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Auth Section — Sole orchestrator for login/logout flows
// ══════════════════════════════════════════════════════════════

class _AuthSection extends ConsumerStatefulWidget {
  const _AuthSection();

  @override
  ConsumerState<_AuthSection> createState() => _AuthSectionState();
}

class _AuthSectionState extends ConsumerState<_AuthSection> {
  bool _isSigningIn = false;

  /// Guards against destructive UI rebuilds while the login dialog is open.
  /// When true, auth state changes won't trigger login/logout UI switch.
  bool _authFlowInProgress = false;

  // ── Login Flow (Orchestrator) ───────────────────────────────

  Future<void> _handleSignIn() async {
    if (_isSigningIn || _authFlowInProgress) return;
    setState(() {
      _isSigningIn = true;
      _authFlowInProgress = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final localCoins = CoinService().coinNotifier.value;

      // Read local journal entries
      final prefs = await SharedPreferences.getInstance();
      final localEntries = await ArchipelagoRepository(prefs).loadHistory();

      // Step 1: Pure Google sign-in (no sync)
      final user = await authService.signInWithGoogle();
      if (user == null) {
        // User cancelled Google sign-in
        return;
      }

      if (!mounted) return;

      // Step 2: Fetch cloud state (parallel, independent)
      final results = await Future.wait([
        CloudSyncService().fetchCloudCoins(user),
        JournalSyncService().cloudJournalExists(user),
      ]);
      final cloudCoins = results[0] as int?;
      final hasCloudJournal = results[1] as bool;

      if (!mounted) return;

      // Step 3: Decision logic — combined boolean
      final hasExistingAccountData =
          (cloudCoins != null) || hasCloudJournal;

      if (hasExistingAccountData) {
        // ── CASE A: Cloud account exists ──
        final confirmed = await _showLoginDialogCaseA(
          context,
          localCoins: localCoins,
          cloudCoins: cloudCoins ?? 0,
        );

        if (confirmed != true) {
          // Cancel → revert login silently
          await authService.signOut();
          return;
        }

        // Confirm → cloud wins (sequential, independent calls)
        await CloudSyncService().applyCloudToLocal(user);
        await JournalSyncService().applyCloudToLocal(user);
        // Rehydrate Riverpod state from updated SharedPreferences
        await ref.read(archipelagoProvider.notifier).reloadFromStorage();
      } else {
        // ── CASE B: First login (no cloud data) ──
        final confirmed = await _showLoginDialogCaseB(
          context,
          localCoins: localCoins,
        );

        if (confirmed != true) {
          await authService.signOut();
          return;
        }

        // Confirm → atomic upload (both must succeed)
        try {
          await CloudSyncService().uploadLocalToCloud(user, localCoins);
          await JournalSyncService().uploadLocalToCloud(user, localEntries);
        } catch (_) {
          // Rollback: revert login, state unchanged
          await authService.signOut();
          return;
        }
      }
    } catch (e) {
      debugPrint('[Drawer] _handleSignIn error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
          _authFlowInProgress = false;
        });
      }
    }
  }

  // ── Logout Flow ─────────────────────────────────────────────

  Future<void> _handleSignOut() async {
    final confirmed = await _showLogoutDialog(context);
    if (confirmed != true) return;

    final authService = ref.read(authServiceProvider);
    // Order: signOut first, then reset local (coins + journal storage + journal UI state)
    await authService.signOut();
    await CoinService().resetToGuest();
    await JournalSyncService().resetToGuest();       // clears SharedPreferences
    await ThemeUnlockService().resetToGuest();       // clears unlocked themes
    ref.read(themeProvider.notifier).resetToDefault(); // force default themes for guest
    ref.read(archipelagoProvider.notifier).clearHistory(); // clears Riverpod state
  }

  // ── Dialogs ─────────────────────────────────────────────────

  /// Case A: Cloud doc exists. Ask user to replace guest with cloud.
  Future<bool?> _showLoginDialogCaseA(
    BuildContext context, {
    required int localCoins,
    required int cloudCoins,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.skyBottom,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign in to your account',
          style: AppTextStyles.subHeading.copyWith(fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your guest data (coins + journal) will be replaced with your saved account data.',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textSub,
              ),
            ),
            const SizedBox(height: 16),
            _CoinComparisonRow(label: 'Guest coins', coins: localCoins),
            const SizedBox(height: 8),
            _CoinComparisonRow(
              label: 'Account coins',
              coins: cloudCoins,
              highlight: true,
            ),
            const SizedBox(height: 16),
            Text(
              'This action cannot be undone.',
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textSub,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Sign in',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.islandGrass,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Case B: First login. Ask user to transfer guest data.
  Future<bool?> _showLoginDialogCaseB(
    BuildContext context, {
    required int localCoins,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.skyBottom,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'First time sign in',
          style: AppTextStyles.subHeading.copyWith(fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your guest data (coins + journal) will be transferred to this account.',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textSub,
              ),
            ),
            const SizedBox(height: 16),
            _CoinComparisonRow(label: 'Coins to transfer', coins: localCoins),
            const SizedBox(height: 16),
            Text(
              'After logging out, guest mode will reset to 0.',
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: AppColors.textSub,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textSub,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Sign in',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.islandGrass,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Logout confirmation dialog.
  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.skyBottom,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign out',
          style: AppTextStyles.subHeading.copyWith(fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guest mode will start fresh — 0 coins and no journal history.',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textSub,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your account data remains saved in the cloud.',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textSub,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textSub,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Sign out',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        // Guard: don't switch UI while dialog is open
        if (_authFlowInProgress) {
          return _buildLoadingIndicator();
        }
        if (user == null) {
          return _buildSignInButton();
        }
        return _buildUserInfo(user);
      },
      loading: () => _buildLoadingIndicator(),
      error: (_, __) => _buildSignInButton(),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Informational text
        Text(
          "save your progress 👇",
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: AppColors.textSub,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        // Google Sign In button
        GestureDetector(
          onTap: (_isSigningIn || _authFlowInProgress) ? null : _handleSignIn,
          child: AnimatedOpacity(
            opacity: _isSigningIn ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSigningIn)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    )
                  else
                    Image.asset(
                      'assets/icons/google_logo.png',
                      width: 20,
                      height: 20,
                    ),
                  const SizedBox(width: 12),
                  Text(
                    _isSigningIn ? "Signing in..." : "Sign in with Google",
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w500,
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

  Widget _buildUserInfo(dynamic user) {
    return Row(
      children: [
        // Profile photo
        if (user.photoURL != null)
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(user.photoURL!),
          )
        else
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.islandGrass.withValues(alpha: 0.3),
            child: Text(
              user.displayName?.substring(0, 1).toUpperCase() ?? "U",
              style: AppTextStyles.subHeading.copyWith(fontSize: 16),
            ),
          ),
        const SizedBox(width: 12),
        // Name + email
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.displayName ?? "User",
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (user.email != null)
                Text(
                  user.email!,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11,
                    color: AppColors.textSub,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        // Sign out button
        IconButton(
          onPressed: _handleSignOut,
          icon: Icon(
            Icons.logout_rounded,
            size: 20,
            color: AppColors.textSub,
          ),
          tooltip: "Sign Out",
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

// ── Helper widget for coin comparison rows ────────────────────

class _CoinComparisonRow extends StatelessWidget {
  final String label;
  final int coins;
  final bool highlight;

  const _CoinComparisonRow({
    required this.label,
    required this.coins,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: highlight ? AppColors.textMain : AppColors.textSub,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪙 ', style: TextStyle(fontSize: 14)),
            Text(
              '$coins',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: highlight ? AppColors.islandGrass : AppColors.textMain,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
