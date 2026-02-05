import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_provider.dart';

class FeatureDiscoveryState {
  final bool hasSeenFocusHint;
  final bool hasSeenTagHint;
  final bool hasSeenCalendarHint;
  final bool hasSeenStatsHint;
  final bool hasSeenThemeHint;

  const FeatureDiscoveryState({
    this.hasSeenFocusHint = false,
    this.hasSeenTagHint = false,
    this.hasSeenCalendarHint = false,
    this.hasSeenStatsHint = false,
    this.hasSeenThemeHint = false,
  });

  FeatureDiscoveryState copyWith({
    bool? hasSeenFocusHint,
    bool? hasSeenTagHint,
    bool? hasSeenCalendarHint,
    bool? hasSeenStatsHint,
    bool? hasSeenThemeHint,
  }) {
    return FeatureDiscoveryState(
      hasSeenFocusHint: hasSeenFocusHint ?? this.hasSeenFocusHint,
      hasSeenTagHint: hasSeenTagHint ?? this.hasSeenTagHint,
      hasSeenCalendarHint: hasSeenCalendarHint ?? this.hasSeenCalendarHint,
      hasSeenStatsHint: hasSeenStatsHint ?? this.hasSeenStatsHint,
      hasSeenThemeHint: hasSeenThemeHint ?? this.hasSeenThemeHint,
    );
  }
}

class FeatureDiscoveryNotifier extends StateNotifier<FeatureDiscoveryState> {
  static const _focusKey = 'hasSeenFocusHint';
  static const _tagKey = 'hasSeenTagHint';
  static const _calendarKey = 'hasSeenCalendarHint';
  static const _statsKey = 'hasSeenStatsHint';
  static const _themeKey = 'hasSeenThemeHint';

  final SharedPreferences _prefs;

  FeatureDiscoveryNotifier(this._prefs) : super(const FeatureDiscoveryState()) {
    _load();
  }

  void _load() {
    state = FeatureDiscoveryState(
      hasSeenFocusHint: _prefs.getBool(_focusKey) ?? false,
      hasSeenTagHint: _prefs.getBool(_tagKey) ?? false,
      hasSeenCalendarHint: _prefs.getBool(_calendarKey) ?? false,
      hasSeenStatsHint: _prefs.getBool(_statsKey) ?? false,
      hasSeenThemeHint: _prefs.getBool(_themeKey) ?? false,
    );
  }

  void markFocusHintSeen() => _setFlag(_focusKey, (state) => state.copyWith(hasSeenFocusHint: true));
  void markTagHintSeen() => _setFlag(_tagKey, (state) => state.copyWith(hasSeenTagHint: true));
  void markCalendarHintSeen() => _setFlag(_calendarKey, (state) => state.copyWith(hasSeenCalendarHint: true));
  void markStatsHintSeen() => _setFlag(_statsKey, (state) => state.copyWith(hasSeenStatsHint: true));
  void markThemeHintSeen() => _setFlag(_themeKey, (state) => state.copyWith(hasSeenThemeHint: true));

  void _setFlag(String key, FeatureDiscoveryState Function(FeatureDiscoveryState) update) {
    if (_prefs.getBool(key) == true) return;
    _prefs.setBool(key, true);
    state = update(state);
  }
}

final featureDiscoveryProvider =
    StateNotifierProvider<FeatureDiscoveryNotifier, FeatureDiscoveryState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FeatureDiscoveryNotifier(prefs);
});
