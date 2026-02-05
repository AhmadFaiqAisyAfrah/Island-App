import 'package:shared_preferences/shared_preferences.dart';

const String hasSeenOnboardingKey = 'has_seen_onboarding';
const String _legacyOnboardingCompleteKey = 'onboarding_complete';

class OnboardingStorage {
  final SharedPreferences prefs;

  const OnboardingStorage(this.prefs);

  bool get hasSeenOnboarding =>
      prefs.getBool(hasSeenOnboardingKey) ??
      prefs.getBool(_legacyOnboardingCompleteKey) ??
      false;

  Future<void> setComplete() async {
    await prefs.setBool(hasSeenOnboardingKey, true);
  }
}
