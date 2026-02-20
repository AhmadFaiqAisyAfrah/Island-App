import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../config/dev_flags.dart'; // Temporary development override for design/testing
import '../../../../services/point_service.dart';
import '../../../../core/data/shared_preferences_provider.dart';
import '../../shop/data/theme_catalog.dart';
import '../../shop/presentation/shop_screen.dart';
import '../../../../domain/monetization/monetization_types.dart';

class ThemeSeasonalPage extends ConsumerWidget {
  const ThemeSeasonalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    final pointService = PointService(prefs);
    final currentPoints = pointService.getCurrentPoints();

    return Scaffold(
      backgroundColor: AppColors.skyBottom,
      appBar: AppBar(
        title: Text("Seasons", style: AppTextStyles.heading.copyWith(fontSize: 20)),
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
          itemCount: ThemeCatalog.seasonal.length,
          itemBuilder: (context, index) {
            final item = ThemeCatalog.seasonal[index];
            // Temporary development override for design/testing
            final isLocked = DEV_UNLOCK_ALL ? false : item.accessType != ItemAccessType.free;
            final canAfford = item.pointCost != null 
                ? currentPoints >= item.pointCost! 
                : true;
            final isSelected = _isSeasonSelected(state, item.id);
            
            return _ThemeCard(
              item: item,
              isSelected: isSelected,
              isLocked: isLocked,
              canAfford: canAfford,
              // Temporary development override for design/testing
              onTap: isLocked
                  ? () => _navigateToShop(context, item)
                  : () => _selectSeason(ref, item.id),
            );
          },
        ),
      ),
    );
  }

  bool _isSeasonSelected(ThemeState state, String itemId) {
    final seasonMap = {
      'season_normal': AppSeason.normal,
      'season_sakura': AppSeason.sakura,
      'season_autumn': AppSeason.autumn,
      'season_winter': AppSeason.winter,
    };
    return seasonMap[itemId] == state.season;
  }

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

  void _navigateToShop(BuildContext context, MonetizableThemeItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShopScreen()),
    );
  }
}

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(item),
                              )
                            : _buildPlaceholder(item),
                      ),
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

  Widget _buildPlaceholder(MonetizableThemeItem item) {
    IconData iconData = Icons.calendar_today;
    
    return Container(
      color: item.accentColor.withOpacity(0.3),
      child: Center(
        child: Icon(
          iconData,
          size: 32,
          color: item.accentColor.withOpacity(0.8),
        ),
      ),
    );
  }
}
