import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/island_coin_icon.dart';
import '../../../../core/services/billing_service.dart';
import '../../../../core/services/coin_service.dart';
import '../../../../services/ad_service.dart';


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
  bool _isAdLoading = false;
  String? _billingError;  // null = OK, non-null = error message

  @override
  void initState() {
    super.initState();
    _initBilling();
  }

  Future<void> _initBilling() async {
    debugPrint('[Shop] ▶ _initBilling() STARTED');
    _billing.onPurchaseUpdated = _refreshState;

    await _billing.init();
    debugPrint('[Shop] ✔ _billing.init() complete');
    debugPrint('[Shop] billing.isAvailable: ${_billing.isAvailable}');
    debugPrint('[Shop] billing.products.length: ${_billing.products.length}');

    // Determine error state
    if (!_billing.isAvailable) {
      _billingError = 'Google Play is not available on this device.';
    } else if (_billing.products.isEmpty) {
      _billingError = 'Coin packages not found. Check Play Console product IDs.';
    }

    await _refreshState();
  }

  Future<void> _refreshState() async {
    // Reload coin notifier from disk so ValueListenableBuilder updates
    final coins = await _coinService.getCoins();
    _coinService.coinNotifier.value = coins;

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _watchAdForPoints() async {
    if (_isAdLoading) return;
    
    setState(() => _isAdLoading = true);

    final adShown = await AdService().showRewardedAd(
      onEarned: (reward) async {
        final points = 5;
        await _coinService.addCoins(points);
        await _refreshState();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('+$points coins earned!'),
              backgroundColor: AppColors.islandGrass,
            ),
          );
        }
      },
    );

    if (mounted) {
      setState(() => _isAdLoading = false);
      
      if (!adShown) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad not available. Try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  bool get _isGuest => FirebaseAuth.instance.currentUser == null;

  /// Guards purchase behind login. Shows dialog if guest.
  void _handlePurchase(String productId) {
    if (_isGuest) {
      _showLoginRequiredDialog();
      return;
    }
    _billing.buyConsumable(productId);
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.skyBottom,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign in required',
          style: AppTextStyles.subHeading.copyWith(fontSize: 18),
        ),
        content: Text(
          'Purchases are permanently saved to your account.\nGuest mode does not support coin purchases.',
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: AppColors.textSub,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textSub,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Go back to drawer to sign in
            },
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
                  // ── Balance ── (reactive via CoinService.coinNotifier)
                  ValueListenableBuilder<int>(
                    valueListenable: CoinService().coinNotifier,
                    builder: (context, coins, _) => _BalanceHeader(points: coins),
                  ),
                  const SizedBox(height: 16),

                  // ── Watch Ad for Points ──
                  _WatchAdCard(
                    onWatchAd: _watchAdForPoints,
                    isLoading: _isAdLoading,
                  ),
                  const SizedBox(height: 24),

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

                  if (_billingError != null)
                    _UnavailableNotice(message: _billingError!)
                  else if (_coinProducts.isEmpty)
                    const _UnavailableNotice(
                        message: "No coin packages available.")
                  else
                    ..._coinProducts.map((product) {
                      final coins = _extractCoinAmount(product.id);
                      return _CoinBundleCard(
                        coins: coins,
                        price: product.price,
                        isGuest: _isGuest,
                        onBuy: () => _handlePurchase(product.id),
                      );
                    }),


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

// ── Watch Ad Card ────────────────────────────────────────────

class _WatchAdCard extends StatelessWidget {
  final VoidCallback onWatchAd;
  final bool isLoading;

  const _WatchAdCard({
    required this.onWatchAd,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onWatchAd,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFFB800),
                          ),
                        )
                      : const Icon(
                          Icons.play_circle_outline_rounded,
                          size: 28,
                          color: Color(0xFFFFB800),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Get Free Coins",
                      style: AppTextStyles.subHeading.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Watch an ad to earn 5 coins",
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: AppColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFB800),
                  ),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFFFB800),
                  size: 16,
                ),
            ],
          ),
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
  final bool isGuest;

  const _CoinBundleCard({
    required this.coins,
    required this.price,
    required this.onBuy,
    this.isGuest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isGuest ? 0.4 : 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.islandGrass.withValues(alpha: 0.2)),
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
                  Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
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
                if (isGuest)
                  Text(
                    'Login required',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: Colors.red.shade300,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
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
                backgroundColor: isGuest
                    ? AppColors.islandGrass.withValues(alpha: 0.4)
                    : AppColors.islandGrass,
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
