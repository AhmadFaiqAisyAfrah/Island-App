import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/data/feature_discovery_provider.dart';
import '../../../../core/widgets/glass_hint.dart';
import '../../shop/presentation/shop_screen.dart';
import '../../shop/data/theme_catalog.dart';
import '../../../../core/data/shared_preferences_provider.dart';
import '../../../../services/point_service.dart';
import '../../../../domain/monetization/monetization_types.dart';

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
    final state = ref.watch(themeProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    final pointService = PointService(prefs);
    final currentPoints = pointService.getCurrentPoints();

    return AlertDialog(
      backgroundColor: AppColors.skyBottom,
      contentPadding: const EdgeInsets.all(24),
      title: Text("Select Theme", style: AppTextStyles.heading.copyWith(fontSize: 24)),
      content: SingleChildScrollView(
        child: SizedBox(
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
              
              // SEASONAL - From ThemeCatalog
              _buildCategorySection(
                title: "Seasonal",
                items: ThemeCatalog.seasonal,
                currentPoints: currentPoints,
                isSelected: (item) => _isSeasonSelected(state, item.id),
                onSelect: (item) => _selectSeason(ref, item.id),
              ),
              
              const SizedBox(height: 24),
              
              // ENVIRONMENT - From ThemeCatalog
              _buildCategorySection(
                title: "Environment",
                items: ThemeCatalog.environments,
                currentPoints: currentPoints,
                isSelected: (item) => _isEnvironmentSelected(state, item.id),
                onSelect: (item) => _selectEnvironment(ref, item.id),
              ),

              const SizedBox(height: 24),

              // HOUSE - From ThemeCatalog
              _buildCategorySection(
                title: "House",
                items: ThemeCatalog.houses,
                currentPoints: currentPoints,
                isSelected: (item) => _isHouseSelected(state, item.id),
                onSelect: (item) => _selectHouse(ref, item.id),
              ),
            ],
          ),
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

  // Build a category section from ThemeCatalog items
  Widget _buildCategorySection({
    required String title,
    required List<MonetizableThemeItem> items,
    required int currentPoints,
    required bool Function(MonetizableThemeItem) isSelected,
    required void Function(MonetizableThemeItem) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: AppColors.textSub,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: items.map((item) {
            final isLocked = item.accessType != ItemAccessType.free;
            final canAfford = item.pointCost != null 
                ? currentPoints >= item.pointCost! 
                : true;
            
            return _ThemeCard(
              item: item,
              isSelected: isSelected(item),
              isLocked: isLocked,
              canAfford: canAfford,
              onTap: isLocked
                  ? () => _navigateToShop(item)
                  : () => onSelect(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Navigation to Shop with item highlighting (preparation for Phase 3)
  void _navigateToShop(MonetizableThemeItem item) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShopScreen(),
        // In Phase 3, pass selectedItemId to auto-scroll and highlight
      ),
    );
  }

  // Selection checkers - Map ThemeCatalog IDs to current state
  bool _isSeasonSelected(ThemeState state, String itemId) {
    final seasonMap = {
      'season_normal': AppSeason.normal,
      'season_sakura': AppSeason.sakura,
      'season_autumn': AppSeason.autumn,
      'season_winter': AppSeason.winter,
    };
    return seasonMap[itemId] == state.season;
  }

  bool _isEnvironmentSelected(ThemeState state, String itemId) {
    final envMap = {
      'env_default': AppEnvironment.defaultSky,
      'env_mountain': AppEnvironment.mountain,
      'env_beach': AppEnvironment.beach,
      'env_forest': AppEnvironment.forest,
    };
    return envMap[itemId] == state.environment;
  }

  bool _isHouseSelected(ThemeState state, String itemId) {
    final houseMap = {
      'house_default': AppHouse.defaultHouse,
      'house_adventure': AppHouse.adventureHouse,
      'house_stargazer': AppHouse.stargazerHut,
      'house_forest': AppHouse.forestCabin,
    };
    return houseMap[itemId] == state.house;
  }

  // Selection actions - Map ThemeCatalog IDs to notifier calls
  void _selectSeason(WidgetRef ref, String itemId) {
    final seasonMap = {
      'season_normal': AppSeason.normal,
      'season_sakura': AppSeason.sakura,
      'season_autumn': AppSeason.autumn,
      'season_winter': AppSeason.winter,
    };
    final season = seasonMap[itemId];
    if (season != null) {
      ref.read(themeProvider.notifier).setSeason(season);
    }
  }

  void _selectEnvironment(WidgetRef ref, String itemId) {
    final envMap = {
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

  void _selectHouse(WidgetRef ref, String itemId) {
    final houseMap = {
      'house_default': AppHouse.defaultHouse,
      'house_adventure': AppHouse.adventureHouse,
      'house_stargazer': AppHouse.stargazerHut,
      'house_forest': AppHouse.forestCabin,
    };
    final house = houseMap[itemId];
    if (house != null) {
      ref.read(themeProvider.notifier).setHouse(house);
    }
  }
}

/// Theme Card - Uses MonetizableThemeItem directly
class _ThemeCard extends StatelessWidget {
  final MonetizableThemeItem item;
  final bool isSelected;
  final bool isLocked;
  final bool canAfford;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.item,
    required this.isSelected,
    required this.isLocked,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 110;
    const double cardHeight = 120;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: isLocked ? Colors.grey.withOpacity(0.3) : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: AppColors.islandGrass, width: 3)
                : Border.all(color: isLocked ? Colors.grey.withOpacity(0.4) : Colors.white.withOpacity(0.2), width: 1),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.islandGrass.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Column(
              children: [
                // IMAGE AREA
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: item.accentColor.withOpacity(isLocked ? 0.1 : 0.3),
                        child: item.assetPath.isNotEmpty
                            ? Image.asset(
                                item.assetPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Placeholder when asset is missing
                                  return _buildPlaceholder(item);
                                },
                              )
                            : _buildPlaceholder(item),
                      ),
                      // LOCK OVERLAY
                      if (isLocked)
                        Container(
                          color: Colors.black.withOpacity(0.4),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getLockIcon(item.accessType),
                                  color: Colors.white.withOpacity(0.9),
                                  size: 24,
                                ),
                                if (item.pointCost != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "${item.pointCost}",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      if (isSelected && !isLocked)
                        Container(
                          color: Colors.black.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 32,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // TEXT AREA
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: isLocked ? Colors.grey.withOpacity(0.2) : Colors.white.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
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
                        // ACCESS TYPE LABEL
                        if (isLocked)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: _getAccessColor(item.accessType).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getAccessLabel(item.accessType),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: _getAccessColor(item.accessType),
                              ),
                            ),
                          ),
                      ],
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

  IconData _getLockIcon(ItemAccessType type) {
    switch (type) {
      case ItemAccessType.pointUnlock:
        return Icons.stars;
      case ItemAccessType.premiumPurchase:
        return Icons.diamond;
      case ItemAccessType.trial:
        return Icons.timer;
      default:
        return Icons.lock;
    }
  }

  String _getAccessLabel(ItemAccessType type) {
    switch (type) {
      case ItemAccessType.pointUnlock:
        return "COINS";
      case ItemAccessType.premiumPurchase:
        return "PREMIUM";
      case ItemAccessType.trial:
        return "TRY";
      default:
        return "LOCKED";
    }
  }

  Color _getAccessColor(ItemAccessType type) {
    switch (type) {
      case ItemAccessType.pointUnlock:
        return Colors.orange;
      case ItemAccessType.premiumPurchase:
        return Colors.purple;
      case ItemAccessType.trial:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Placeholder widget when theme asset is missing
  /// Shows category-appropriate icon with accent color
  Widget _buildPlaceholder(MonetizableThemeItem item) {
    IconData iconData;
    
    // Choose icon based on category
    switch (item.category) {
      case 'house':
        iconData = Icons.home;
        break;
      case 'seasonal':
        iconData = Icons.calendar_today;
        break;
      case 'environment':
        iconData = Icons.landscape;
        break;
      default:
        iconData = Icons.palette;
    }
    
    return Container(
      color: item.accentColor.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 32,
              color: item.accentColor.withOpacity(0.8),
            ),
            if (item.category == 'house')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "House",
                  style: TextStyle(
                    fontSize: 10,
                    color: item.accentColor.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
