import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/point_service.dart';
import '../../../../core/data/shared_preferences_provider.dart';
import '../../../../core/widgets/island_coin_icon.dart';
import 'seasonal_themes_page.dart';
import 'environments_page.dart';
import 'houses_page.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final pointService = PointService(prefs);

    final currentPoints = pointService.getCurrentPoints();

    return Scaffold(
      backgroundColor: AppColors.skyBottom,
      appBar: AppBar(
        title: Text("Island Shop", style: AppTextStyles.heading.copyWith(fontSize: 20)),
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
          children: [
            // BALANCE HEADER
            _BalanceHeader(points: currentPoints),
            const SizedBox(height: 32),

            // COIN BUNDLES (STATIC - NOT COLLAPSIBLE)
            _SectionTitle(title: "Grow Your Island"),
            const SizedBox(height: 4),
            Text(
              "Use coins to unlock themes, environments, and homes.",
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: AppColors.textSub,
              ),
            ),
            const SizedBox(height: 16),
            _CoinBundleCard(
              coins: 200,
              price: "IDR 19.000",
              badge: "Good Start",
              onBuy: () {},
            ),
            _CoinBundleCard(
              coins: 500,
              bonusCoins: 50,
              price: "IDR 39.000",
              badge: "Most Chosen",
              onBuy: () {},
            ),
            _CoinBundleCard(
              coins: 1000,
              bonusCoins: 150,
              price: "IDR 69.000",
              subtext: "Best value for long-term focus",
              onBuy: () {},
            ),
            _CoinBundleCard(
              coins: 2500,
              bonusCoins: 500,
              price: "IDR 149.000",
              subtext: "Support the development of Island 🌱",
              onBuy: () {},
            ),

            const SizedBox(height: 24),

            // NAVIGATION CARDS
            _NavigationCard(
              title: "Seasons",
              iconText: "☃️",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SeasonalThemesPage()),
              ),
            ),

            const SizedBox(height: 12),

            _NavigationCard(
              title: "Environments",
              iconText: "🏔️",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EnvironmentsPage()),
              ),
            ),

            const SizedBox(height: 12),

            _NavigationCard(
              title: "Houses",
              iconText: "🏡",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HousesPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  final int points;
  const _BalanceHeader({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.islandGrass.withOpacity(0.3),
            AppColors.islandGrass.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.islandGrass.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your Island Coins',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: AppColors.textSub,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const IslandCoinIcon(size: 32),
                const SizedBox(width: 8),
                Text(
                  '$points',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 32,
                    color: AppColors.textMain,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.subHeading.copyWith(
        color: AppColors.textMain,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final String title;
  final String iconText;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.iconText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.islandGrass.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    iconText,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.subHeading.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSub,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinBundleCard extends StatelessWidget {
  final int coins;
  final int? bonusCoins;
  final String price;
  final String? badge;
  final String? subtext;
  final VoidCallback onBuy;

  const _CoinBundleCard({
    required this.coins,
    this.bonusCoins,
    required this.price,
    this.badge,
    this.subtext,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.islandGrass.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: const Center(
              child: IslandCoinIcon(size: 36),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$coins',
                      style: AppTextStyles.subHeading.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    if (bonusCoins != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '+$bonusCoins bonus',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.islandGrass,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMain,
                  ),
                ),
                if (subtext != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtext!,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 11,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.islandGrass.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.islandGrass,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: 70,
                child: ElevatedButton(
                  onPressed: onBuy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.islandGrass,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    "Buy",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
