import 'package:flutter/foundation.dart';

class AdConfig {
  static const String _testRewardedAdUnit = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testInterstitialAdUnit = 'ca-app-pub-3940256099942544/8696191438';

  static String get rewardedAdUnitId {
    if (kReleaseMode) {
      return 'ca-app-pub-6763889648869554/3389548536';
    } else {
      return _testRewardedAdUnit;
    }
  }

  static String get interstitialAdUnitId {
    if (kReleaseMode) {
      return 'ca-app-pub-6763889648869554/YOUR_INTERSTITIAL_UNIT_ID';
    } else {
      return _testInterstitialAdUnit;
    }
  }
}
