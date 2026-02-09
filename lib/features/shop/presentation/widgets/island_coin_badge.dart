import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// IslandCoinBadge - Reusable coin display component
/// 
/// Used consistently across:
/// - Dashboard
/// - Shop
/// - Theme selector
/// - Anywhere coin balance is shown
class IslandCoinBadge extends StatelessWidget {
  final int amount;
  final bool showLabel;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? textColor;
  final bool isCompact;

  const IslandCoinBadge({
    super.key,
    required this.amount,
    this.showLabel = false,
    this.iconSize = 20,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.textColor,
    this.isCompact = false,
  });

  /// Compact version for small spaces
  const IslandCoinBadge.compact({
    super.key,
    required this.amount,
    this.showLabel = false,
    this.iconSize = 16,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.textColor,
    this.isCompact = true,
  });

  /// Large version for headers
  const IslandCoinBadge.large({
    super.key,
    required this.amount,
    this.showLabel = false,
    this.iconSize = 28,
    this.fontSize = 32,
    this.fontWeight = FontWeight.bold,
    this.textColor,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coin Icon
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.monetization_on,
              size: iconSize * 0.7,
              color: const Color(0xFFFFA500),
            ),
          ),
        ),
        SizedBox(width: isCompact ? 4 : 8),
        
        // Amount
        Text(
          amount.toString(),
          style: AppTextStyles.subHeading.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor ?? AppColors.textMain,
            letterSpacing: -0.5,
          ),
        ),
        
        // Optional label
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            "Coins",
            style: AppTextStyles.body.copyWith(
              fontSize: fontSize * 0.75,
              color: AppColors.textSub,
            ),
          ),
        ],
      ],
    );
  }
}

/// Island Coin Label - Static text label for "Island Coins"
class IslandCoinLabel extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;

  const IslandCoinLabel({
    super.key,
    this.fontSize = 13,
    this.color,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "Island Coins",
      style: AppTextStyles.body.copyWith(
        fontSize: fontSize,
        color: color ?? AppColors.textSub,
        fontWeight: fontWeight,
      ),
    );
  }
}

/// Cost badge for unlock prices
class IslandCoinCost extends StatelessWidget {
  final int cost;
  final bool canAfford;
  final bool isCompact;

  const IslandCoinCost({
    super.key,
    required this.cost,
    this.canAfford = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 10,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: canAfford 
            ? const Color(0xFFFFD700).withOpacity(0.15)
            : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
        border: Border.all(
          color: canAfford 
              ? const Color(0xFFFFD700).withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on,
            size: isCompact ? 12 : 14,
            color: canAfford ? const Color(0xFFFFA500) : Colors.grey,
          ),
          SizedBox(width: isCompact ? 2 : 4),
          Text(
            "$cost",
            style: AppTextStyles.body.copyWith(
              fontSize: isCompact ? 11 : 13,
              fontWeight: FontWeight.bold,
              color: canAfford ? const Color(0xFFFFA500) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
