import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple integer state for coin balance. 
// Starting balanced at 50 coins (MVP).
class CurrencyNotifier extends StateNotifier<int> {
  CurrencyNotifier() : super(0);

  void addCoins(int amount) {
    state = state + amount;
  }

  // Returns true if purchase successful
  bool tryPurchase(int cost) {
    if (state >= cost) {
      state = state - cost;
      return true;
    }
    return false;
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, int>((ref) {
  return CurrencyNotifier();
});
