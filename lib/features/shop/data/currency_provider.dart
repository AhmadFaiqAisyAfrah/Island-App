import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/data/shared_preferences_provider.dart';

// Simple integer state for coin balance. 
// Starting balanced at 50 coins (MVP).
class CurrencyNotifier extends StateNotifier<int> {
  final SharedPreferences _prefs;
  static const _keyCoins = 'user_coins';

  CurrencyNotifier(this._prefs) : super(0) {
    _loadCoins();
  }

  void _loadCoins() {
    state = _prefs.getInt(_keyCoins) ?? 50; // Default to 50 if new
  }

  void addCoins(int amount) {
    state = state + amount;
    _prefs.setInt(_keyCoins, state);
  }

  // Returns true if purchase successful
  bool tryPurchase(int cost) {
    if (state >= cost) {
      state = state - cost;
      _prefs.setInt(_keyCoins, state);
      return true;
    }
    return false;
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CurrencyNotifier(prefs);
});
