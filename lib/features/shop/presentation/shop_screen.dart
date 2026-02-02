import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../data/currency_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: AppColors.skyBottom, // Use same calming background
      appBar: AppBar(
        title: Text("Shop", style: AppTextStyles.heading.copyWith(fontSize: 20)),
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
          children: [
            // HEADER: Balance
            _BalanceHeader(balance: balance),
            const SizedBox(height: 32),

            // SECTION 1: Buy Coins
            _SectionTitle(title: "Buy Coins"),
            const SizedBox(height: 16),
            const _CoinPackageGrid(),
            
            const SizedBox(height: 32),

            // SECTION 2: Free Coins
            _SectionTitle(title: "Free Coins"),
            const SizedBox(height: 16),
            _FreeAdCard(
              onWatch: () {
                // Simulate Ad Watch
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Watching Ad... (Simulated)"),
                    duration: Duration(milliseconds: 800),
                  )
                );
                
                // Delay to simulate ad time
                Future.delayed(const Duration(seconds: 1), () {
                  ref.read(currencyProvider.notifier).addCoins(20);
                  // Confirmation
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Reward Logic: +20 Coins added!"),
                        backgroundColor: AppColors.islandGrass,
                      )
                    );
                  }
                });
              },
            ),

            const SizedBox(height: 48),

            // FOOTER: Disclaimer
            Text(
              "Purchases are optional.\nYour focus progress is never blocked by payments.",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: AppColors.textSub.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  final int balance;
  const _BalanceHeader({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.islandCliff.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            "Current Balance",
            style: AppTextStyles.body.copyWith(color: AppColors.textSub, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🪙", style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                "$balance",
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.subHeading.copyWith(
          color: AppColors.textMain,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CoinPackageGrid extends StatelessWidget {
  const _CoinPackageGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PackageCard(coins: 100, price: "\$0.99", color: const Color(0xFFE3F2FD)), // Soft Blue
        const SizedBox(height: 12),
        _PackageCard(coins: 300, price: "\$2.99", color: const Color(0xFFF3E5F5)), // Soft Purple
        const SizedBox(height: 12),
        _PackageCard(coins: 800, price: "\$6.99", color: const Color(0xFFFFF3E0)), // Soft Orange
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final int coins;
  final String price;
  final Color color;

  const _PackageCard({
    required this.coins,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Text("🪙", style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$coins Coins", 
                style: AppTextStyles.subHeading.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                "Small pile of focus", 
                style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textSub),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment integration coming soon!"))
               );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textMain,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(price),
          ),
        ],
      ),
    );
  }
}

class _FreeAdCard extends StatelessWidget {
  final VoidCallback onWatch;
  const _FreeAdCard({required this.onWatch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Soft Green
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.islandGrass.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_fill_rounded, color: AppColors.islandGrass, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Watch an ad",
                  style: AppTextStyles.subHeading.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Earn +20 coins immediately",
                  style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textSub),
                ),
                const SizedBox(height: 6),
                 Text(
                  "Available: 5/5 today",
                  style: AppTextStyles.body.copyWith(fontSize: 10, color: AppColors.textSub.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onWatch,
            child: Text("Watch", style: TextStyle(color: AppColors.islandGrass, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
