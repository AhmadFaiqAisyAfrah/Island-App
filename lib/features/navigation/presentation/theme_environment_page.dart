import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/coin_service.dart';
import '../../../../core/services/theme_unlock_service.dart';
import '../../shop/data/theme_catalog.dart';
import '../../shop/presentation/shop_screen.dart';

class ThemeEnvironmentPage extends ConsumerStatefulWidget {
  const ThemeEnvironmentPage({super.key});

  @override
  ConsumerState<ThemeEnvironmentPage> createState() => _ThemeEnvironmentPageState();
}

class _ThemeEnvironmentPageState extends ConsumerState<ThemeEnvironmentPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(themeProvider);

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: ThemeCatalog.environments.length,
          itemBuilder: (context, index) {
            final item = ThemeCatalog.environments[index];
            final isLocked = !item.isDefault && !ThemeUnlockService().isUnlocked(item.id);
            final isSelected = _isEnvironmentSelected(state, item.id);
            
            return _ThemeCard(
              item: item,
              isSelected: isSelected,
              isLocked: isLocked,
              onTap: () => _handleThemeTap(item),
            );
          },
        ),
      ),
    );
  }

  bool _isEnvironmentSelected(ThemeState state, String itemId) {
    const envMap = {
      'env_default': AppEnvironment.defaultSky,
      'env_mountain': AppEnvironment.mountain,
      'env_beach': AppEnvironment.beach,
      'env_forest': AppEnvironment.forest,
    };
    return envMap[itemId] == state.environment;
  }

  void _selectEnvironment(String itemId) {
    const envMap = {
      'env_default': AppEnvironment.defaultSky,
      'env_mountain': AppEnvironment.mountain,
      'env_beach': AppEnvironment.beach,
      'env_forest': AppEnvironment.forest,
    };
    final env = envMap[itemId];
    if (env != null) {
      ref.read(themeProvider.notifier).setEnvironment(env);
    }
  }

  void _handleThemeTap(MonetizableThemeItem item) {
    // Default or already unlocked → apply immediately
    if (item.isDefault || ThemeUnlockService().isUnlocked(item.id)) {
      _selectEnvironment(item.id);
      return;
    }

    // Guest mode → login required
    if (FirebaseAuth.instance.currentUser == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.skyBottom,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Login Required", style: AppTextStyles.heading.copyWith(fontSize: 18)),
          content: Text(
            "You need to log in to unlock themes.",
            style: AppTextStyles.body.copyWith(color: AppColors.textSub),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("OK", style: AppTextStyles.subHeading.copyWith(fontSize: 14)),
            ),
          ],
        ),
      );
      return;
    }

    // Insufficient coins → go to shop
    final coins = CoinService().coinNotifier.value;
    if (coins < item.price) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.skyBottom,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Not Enough Coins", style: AppTextStyles.heading.copyWith(fontSize: 18)),
          content: Text(
            "You need ${item.price} coins to unlock ${item.name}.\nYou currently have $coins coins.",
            style: AppTextStyles.body.copyWith(color: AppColors.textSub),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: AppTextStyles.subHeading.copyWith(fontSize: 14)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
              },
              child: Text("Go to Shop", style: AppTextStyles.subHeading.copyWith(fontSize: 14, color: AppColors.islandGrass)),
            ),
          ],
        ),
      );
      return;
    }

    // Enough coins → confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.skyBottom,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Unlock Theme", style: AppTextStyles.heading.copyWith(fontSize: 18)),
        content: Text(
          "Unlock ${item.name} for ${item.price} coins?",
          style: AppTextStyles.body.copyWith(color: AppColors.textSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: AppTextStyles.subHeading.copyWith(fontSize: 14)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ThemeUnlockService().unlockTheme(item.id, item.price);
              if (success && mounted) {
                _selectEnvironment(item.id);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} unlocked!'),
                    backgroundColor: AppColors.islandGrass,
                  ),
                );
              }
            },
            child: Text("Unlock", style: AppTextStyles.subHeading.copyWith(fontSize: 14, color: AppColors.islandGrass)),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final MonetizableThemeItem item;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.item,
    required this.isSelected,
    required this.isLocked,
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
          decoration: BoxDecoration(
            color: isLocked ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: AppColors.islandGrass, width: 3)
                : Border.all(color: isLocked ? Colors.grey.withOpacity(0.3) : Colors.white.withOpacity(0.2), width: 1),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.islandGrass.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: item.accentColor.withOpacity(isLocked ? 0.15 : 0.3),
                        child: item.assetPath.isNotEmpty
                            ? Image.asset(
                                item.assetPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(item),
                              )
                            : _buildPlaceholder(item),
                      ),
                      if (isLocked)
                        Container(
                          color: Colors.black.withOpacity(0.35),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_rounded,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 22,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.monetization_on_rounded, color: Colors.amber.withOpacity(0.9), size: 14),
                                    const SizedBox(width: 3),
                                    Text(
                                      "${item.price}",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.95),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (isSelected && !isLocked)
                        Container(
                          color: Colors.black.withOpacity(0.1),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: isLocked ? Colors.grey.withOpacity(0.1) : Colors.white.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      item.name,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        height: 1.1,
                        color: isLocked ? Colors.grey : AppColors.textMain,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(MonetizableThemeItem item) {
    return Container(
      color: item.accentColor.withOpacity(0.3),
      child: Center(
        child: Icon(
          Icons.landscape_rounded,
          size: 32,
          color: item.accentColor.withOpacity(0.8),
        ),
      ),
    );
  }
}
