import 'package:flutter/material.dart';

/// Reusable Island Coin Icon widget
/// 
/// Displays the Island Coin visual (tree + house on floating island)
/// Used consistently across Dashboard and Shop
/// 
/// Asset path: assets/images/coins/island_coin.png
class IslandCoinIcon extends StatelessWidget {
  final double size;
  
  const IslandCoinIcon({
    super.key,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/coins/island_coin.png',
      height: size,
      width: size,
      fit: BoxFit.contain,
    );
  }
}
