import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


enum AppThemeMode {
  day,
  night,
}

enum AppSeason {
  normal,
  sakura,
}

@immutable
class ThemeState {
  final AppThemeMode mode;
  final AppSeason season;

  const ThemeState({
    this.mode = AppThemeMode.day,
    this.season = AppSeason.normal,
  });

  ThemeState copyWith({AppThemeMode? mode, AppSeason? season}) {
    return ThemeState(
      mode: mode ?? this.mode,
      season: season ?? this.season,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState && other.mode == mode && other.season == season;
  }

  @override
  int get hashCode => Object.hash(mode, season);
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState());

  void setMode(AppThemeMode mode) {
    state = state.copyWith(mode: mode);
  }
  
  void setSeason(AppSeason season) {
    state = state.copyWith(season: season);
  }
  
  void toggleMode() {
    state = state.copyWith(
      mode: state.mode == AppThemeMode.day ? AppThemeMode.night : AppThemeMode.day
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
