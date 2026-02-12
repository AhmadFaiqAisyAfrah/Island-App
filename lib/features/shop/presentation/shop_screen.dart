import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/point_service.dart';
import '../../../../core/data/shared_preferences_provider.dart';
import '../../../../core/widgets/island_coin_icon.dart';
import '../../../../core/services/billing_service.dart';
import '../../../../core/services/coin_service.dart';
import 'seasonal_themes_page.dart';
import 'environments_page.dart';
import 'houses_page.dart';

// ── Helpers ────────────────────────────────────────────────────

int _extractCoinAmount(String productId) {
  final match = RegExp(r'\d+').firstMatch(productId);
  return match != null ? int.parse(match.group(0)!) : 0;
}

// ── Shop Screen ────────────────────────────────────────────────

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final BillingService _billing = BillingService();
  final CoinService _coinService = CoinService();

  bool _loading = true;
  bool _adsRemoved = false;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _initBilling();
  }

  Future<void> _initBilling() async {
    _billing.onPurchaseUpdated = _refreshState;

    await _billing.init();
    await _refreshState();
  }

  Future<void> _refreshState() async {
    final coins = await _coinService.getCoins();
    final adsRemoved = await _coinService.getRemoveAds();

    if (mounted) {
      setState(() {
        _coins = coins;
        _adsRemoved = adsRemoved;
        _loading = false;
      });
    }
  }

  List<ProductDetails> get _coinProducts {
    final list = _billing.products
        .where((p) => p.id.startsWith('island_coins_'))
        .toList();
    list.sort((a, b) =>
        _extractCoinAmount(a.id).compareTo(_extractCoinAmount(b.id)));
    return list;
  }

  ProductDetails? get _removeAdsProduct {
    try {
      return _billing.products.firstWhere((p) => p.id == 'island_remove_ads');
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyBottom,
      appBar: AppBar(
        title: Text("Island Shop",
            style: AppTextStyles.heading.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.islandGrass,
                strokeWidth: 2,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Balance ──
                  _BalanceHeader(points: _coins),
                  const SizedBox(height: 32),

                  // ── Coin Bundles ──
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

                  if (_coinProducts.isEmpty)
                    _UnavailableNotice(
                        message: "Coin packages are loading…")
                  else
                    ..._coinProducts.map((product) {
                      final coins = _extractCoinAmount(product.id);
                      return _CoinBundleCard(
                        coins: coins,
                        price: product.price,
                        onBuy: () =>
                            _billing.buyConsumable(product.id),
                      );
                    }),

                  const SizedBox(height: 8),

                  // ── Remove Ads ──
                  if (_removeAdsProduct != null)
                    _RemoveAdsCard(
                      price: _removeAdsProduct!.price,
                      purchased: _adsRemoved,
                      onBuy: () =>
                          _billing.buyNonConsumable('island_remove_ads'),
                    ),

                  const SizedBox(height: 24),

                  // ── Navigation Cards ──
                  _NavigationCard(
                    title: "Seasons",
                    iconText: "☃️",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SeasonalThemesPage()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _NavigationCard(
                    title: "Environments",
                    iconText: "🏔️",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EnvironmentsPage()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _NavigationCard(
                    title: "Houses",
                    iconText: "🏡",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HousesPage()),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Balance Header ─────────────────────────────────────────────

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
          children: [
            Text(
              'Your Island Coins',
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: AppColors.textSub,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
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

// ── Section Title ──────────────────────────────────────────────

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

// ── Coin Bundle Card ───────────────────────────────────────────

class _CoinBundleCard extends StatelessWidget {
  final int coins;
  final String price;
  final VoidCallback onBuy;

  const _CoinBundleCard({
    required this.coins,
    required this.price,
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
              border:
                  Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
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
                Text(
                  '$coins Coins',
                  style: AppTextStyles.subHeading.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSub,
                  ),
                ),
              ],
            ),
          ),
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
    );
  }
}

// ── Remove Ads Card ────────────────────────────────────────────

class _RemoveAdsCard extends StatelessWidget {
  final String price;
  final bool purchased;
  final VoidCallback onBuy;

  const _RemoveAdsCard({
    required this.price,
    required this.purchased,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: purchased
              ? AppColors.islandGrass.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: purchased
                  ? AppColors.islandGrass.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                purchased ? Icons.check_circle_rounded : Icons.block_rounded,
                size: 28,
                color: purchased ? AppColors.islandGrass : AppColors.textSub,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Remove Ads",
                  style: AppTextStyles.subHeading.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  purchased
                      ? "Ads removed. Thank you!"
                      : "Enjoy Island without interruptions.",
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          if (purchased)
            Text(
              "Active",
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.islandGrass,
              ),
            )
          else
            ElevatedButton(
              onPressed: onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textMain.withOpacity(0.85),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(
                price,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Navigation Card ────────────────────────────────────────────

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

// ── Unavailable Notice ─────────────────────────────────────────

class _UnavailableNotice extends StatelessWidget {
  final String message;
  const _UnavailableNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: AppColors.textSub,
          ),
        ),
      ),
    );
  }
}
