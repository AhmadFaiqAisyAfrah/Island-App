import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../config/ad_config.dart';
import '../core/services/coin_service.dart';

class AdService {
  AdService._();
  static final AdService _instance = AdService._();
  factory AdService() => _instance;

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _isInitialized = false;

  bool get isRewardedAdReady => _rewardedAd != null;
  bool get isInterstitialAdReady => _interstitialAd != null;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await MobileAds.instance.initialize();
    await loadRewardedAd();
    await loadInterstitialAd();
  }

  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          debugPrint('[AdService] Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Rewarded ad failed to load: ${error.message}');
          _rewardedAd = null;
        },
      ),
    );
  }

  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('[AdService] Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Interstitial ad failed to load: ${error.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Show a rewarded ad. All users can watch ads for coins.
  Future<bool> showRewardedAd({required Function(RewardItem) onEarned}) async {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onEarned(reward);
        },
      );
      _rewardedAd = null;
      await loadRewardedAd();
      return true;
    } else {
      debugPrint('[AdService] Rewarded ad not ready');
      await loadRewardedAd();
      return false;
    }
  }

  /// Show interstitial ad. Blocked for premium users.
  Future<bool> showInterstitialAd() async {
    final isPremium = await CoinService().getRemoveAds();
    if (isPremium) {
      debugPrint('[AdService] User is premium, not showing interstitial ad');
      return false;
    }

    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      await loadInterstitialAd();
      return true;
    } else {
      debugPrint('[AdService] Interstitial ad not ready');
      await loadInterstitialAd();
      return false;
    }
  }

  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
