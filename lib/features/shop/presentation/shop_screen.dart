import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/point_service.dart';
import '../../../../services/trial_service.dart';
import '../../../../core/data/shared_preferences_provider.dart';
import '../data/theme_catalog.dart';
import '../../../domain/monetization/monetization.dart';
import '../../../../core/widgets/island_coin_icon.dart';

/// Shop Screen - Monetization Phase 2
/// 
/// READ ONLY UI - No ads, no payments, no side effects
/// Displays point balance and monetizable items with visual states
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final pointService = PointService(prefs);
    final trialService = TrialService(prefs);
    
    final currentPoints = pointService.getCurrentPoints();
    final canShowTrial = trialService.canShowTrialOfferToday();

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

            const SizedBox(height: 32),

            // COLLAPSIBLE SHOP SECTIONS
            _CollapsibleSection(
              title: "Seasonal Themes",
              initiallyExpanded: false,
              children: ThemeCatalog.seasonal.map((item) => _ThemeItemCard(
                item: item,
                currentPoints: currentPoints,
                canShowTrial: canShowTrial,
                isTrialActive: trialService.isTrialActiveFor(item.id),
              )).toList(),
            ),
            
            const SizedBox(height: 16),

            _CollapsibleSection(
              title: "Environments",
              initiallyExpanded: false,
              children: ThemeCatalog.environments.map((item) => _ThemeItemCard(
                item: item,
                currentPoints: currentPoints,
                canShowTrial: canShowTrial,
                isTrialActive: trialService.isTrialActiveFor(item.id),
              )).toList(),
            ),

            const SizedBox(height: 16),

            _CollapsibleSection(
              title: "Houses",
              initiallyExpanded: false,
              children: ThemeCatalog.houses.map((item) => _ThemeItemCard(
                item: item,
                currentPoints: currentPoints,
                canShowTrial: canShowTrial,
                isTrialActive: trialService.isTrialActiveFor(item.id),
              )).toList(),
            ),

            const SizedBox(height: 48),

            // FOOTER
            _buildFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            "How to Earn Island Coins",
            style: AppTextStyles.subHeading.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildEarningRow("🎯", "Focus Session", "+2 coins/min"),
          const SizedBox(height: 8),
          _buildEarningRow("🎁", "Welcome Bonus", "+100 coins"),
          const SizedBox(height: 8),
          _buildEarningRow("📺", "Watch Ads", "+50 coins (coming soon)"),
        ],
      ),
    );
  }

  Widget _buildEarningRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(fontSize: 13),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.islandGrass,
          ),
        ),
      ],
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

class _ThemeItemCard extends StatelessWidget {
  final MonetizableThemeItem item;
  final int currentPoints;
  final bool canShowTrial;
  final bool isTrialActive;

  const _ThemeItemCard({
    required this.item,
    required this.currentPoints,
    required this.canShowTrial,
    required this.isTrialActive,
  });

  @override
  Widget build(BuildContext context) {
    final bool canAfford = item.pointCost != null && currentPoints >= item.pointCost!;
    final bool showTrialButton = item.supportsTrial && canShowTrial && !isTrialActive;
    final bool isLocked = item.accessType != ItemAccessType.free;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: isLocked 
            ? Border.all(color: Colors.grey.withOpacity(0.3))
            : Border.all(color: item.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // PREVIEW
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: item.accentColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isLocked 
                ? Icon(Icons.lock, color: Colors.grey.withOpacity(0.6), size: 28)
                : Icon(Icons.check_circle, color: AppColors.islandGrass, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          
          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.subHeading.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey : AppColors.textMain,
                        ),
                      ),
                    ),
                    if (isTrialActive)
                      _StatusBadge(
                        text: "ON TRIAL",
                        color: AppColors.islandGrass,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.textSub,
                  ),
                ),
                const SizedBox(height: 8),
                
                // ACCESS INDICATOR
                if (item.accessType == ItemAccessType.free)
                  _AccessLabel(icon: Icons.check, text: "Free", color: AppColors.islandGrass)
                else if (item.accessType == ItemAccessType.pointUnlock && item.pointCost != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: canAfford
                          ? const Color(0xFFFFD700).withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: canAfford
                            ? const Color(0xFFFFD700).withOpacity(0.5)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IslandCoinIcon(size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${item.pointCost}',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: canAfford ? const Color(0xFFFFA500) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (item.accessType == ItemAccessType.premiumPurchase)
                  _AccessLabel(
                    icon: Icons.diamond,
                    text: "Premium",
                    color: Colors.purple,
                    isLocked: true,
                  )
                else if (item.accessType == ItemAccessType.trial)
                  _AccessLabel(
                    icon: Icons.timer,
                    text: "Try Free",
                    color: canShowTrial ? Colors.blue : Colors.grey,
                    isLocked: !canShowTrial,
                  ),
              ],
            ),
          ),

          // ACTION BUTTONS
          if (isLocked) ...[
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // UNLOCK BUTTON
                if (item.isPointUnlock)
                  _ActionButton(
                    label: "Unlock",
                    isEnabled: canAfford,
                    onPressed: canAfford ? () {} : null,
                  ),
                
                // TRIAL BUTTON
                if (showTrialButton) ...[
                  if (item.isPointUnlock) const SizedBox(height: 8),
                  _ActionButton(
                    label: "Try",
                    isEnabled: true,
                    isSecondary: true,
                    onPressed: () {},
                  ),
                ],

                // PREMIUM LABEL
                if (item.isPremium)
                  Text(
                    "Soon",
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AccessLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isLocked;

  const _AccessLabel({
    required this.icon,
    required this.text,
    required this.color,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.withOpacity(0.1) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isLocked ? Colors.grey : color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isLocked ? Colors.grey : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isEnabled;
  final bool isSecondary;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.isEnabled,
    this.isSecondary = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary 
              ? Colors.white 
              : (isEnabled ? AppColors.islandGrass : Colors.grey.withOpacity(0.3)),
          foregroundColor: isSecondary ? AppColors.islandGrass : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isSecondary 
                ? BorderSide(color: AppColors.islandGrass.withOpacity(0.3))
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isEnabled 
                ? (isSecondary ? AppColors.islandGrass : Colors.white)
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _CollapsibleSection({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Section Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
              bottom: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.subHeading.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSub,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: widget.children,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
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
          // Coin Icon
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
          
          // INFO
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

          // BADGE & BUTTON
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
