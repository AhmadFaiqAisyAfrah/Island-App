import 'package:shared_preferences/shared_preferences.dart';

/// Persistence layer for coins and ad-removal state.
/// Uses SharedPreferences for lightweight local storage.
class CoinService {
  static const _coinsKey = 'island_coins';
  static const _removeAdsKey = 'island_remove_ads';

  CoinService._();
  static final CoinService _instance = CoinService._();
  factory CoinService() => _instance;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get current coin balance.
  Future<int> getCoins() async {
    final prefs = await _preferences;
    return prefs.getInt(_coinsKey) ?? 0;
  }

  /// Add coins to current balance. Returns new total.
  Future<int> addCoins(int amount) async {
    final current = await getCoins();
    final newTotal = current + amount;
    await setCoins(newTotal);
    return newTotal;
  }

  /// Set coin balance to an exact value.
  Future<void> setCoins(int value) async {
    final prefs = await _preferences;
    await prefs.setInt(_coinsKey, value);
  }

  /// Check if ads have been removed.
  Future<bool> getRemoveAds() async {
    final prefs = await _preferences;
    return prefs.getBool(_removeAdsKey) ?? false;
  }

  /// Set ad-removal state.
  Future<void> setRemoveAds(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_removeAdsKey, value);
  }
}
