import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  AdService._();
  static final AdService _instance = AdService._();
  factory AdService() => _instance;

  static const String testRewardedAdUnit = 'ca-app-pub-3940256099942544/5224354917';

  RewardedAd? _rewardedAd;
  bool _isInitialized = false;

  bool get isRewardedAdReady => _rewardedAd != null;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await MobileAds.instance.initialize();
    await loadRewardedAd();
  }

  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: testRewardedAdUnit,
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

  void dispose() {
    _rewardedAd?.dispose();
  }
}
