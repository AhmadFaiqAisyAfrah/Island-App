import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/data/shared_preferences_provider.dart';


enum AppThemeMode {
  day,
  night,
}

enum AppSeason {
  normal,
  sakura,
  autumn,
  winter,
}

enum AppEnvironment {
  defaultSky,
  mountain,
  beach,
  forest,
}

enum AppHouse {
  defaultHouse,
  adventureHouse,
}

@immutable
class ThemeState {
  final AppThemeMode mode;
  final AppSeason season;
  final AppEnvironment environment;
  final AppHouse house;

  const ThemeState({
    this.mode = AppThemeMode.day,
    this.season = AppSeason.normal,
    this.environment = AppEnvironment.defaultSky,
    this.house = AppHouse.defaultHouse,
  });

  ThemeState copyWith({
    AppThemeMode? mode,
    AppSeason? season,
    AppEnvironment? environment,
    AppHouse? house,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      season: season ?? this.season,
      environment: environment ?? this.environment,
      house: house ?? this.house,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState && 
           other.mode == mode && 
           other.season == season &&
           other.environment == environment &&
           other.house == house;
  }

  @override
  int get hashCode => Object.hash(mode, season, environment, house);
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences _prefs;
  static const _keyMode = 'theme_mode';
  static const _keySeason = 'theme_season';
  static const _keyEnvironment = 'theme_env';
  static const _keyHouse = 'theme_house';

  ThemeNotifier(this._prefs) : super(const ThemeState()) {
    _loadTheme();
  }

  void _loadTheme() {
    final modeIndex = _prefs.getInt(_keyMode) ?? 0;
    final seasonIndex = _prefs.getInt(_keySeason) ?? 0;
    final envIndex = _prefs.getInt(_keyEnvironment) ?? 0;
    final houseIndex = _prefs.getInt(_keyHouse) ?? 0;

    state = ThemeState(
      mode: AppThemeMode.values.length > modeIndex ? AppThemeMode.values[modeIndex] : AppThemeMode.day,
      season: AppSeason.values.length > seasonIndex ? AppSeason.values[seasonIndex] : AppSeason.normal,
      environment: AppEnvironment.values.length > envIndex ? AppEnvironment.values[envIndex] : AppEnvironment.defaultSky,
      house: AppHouse.values.length > houseIndex ? AppHouse.values[houseIndex] : AppHouse.defaultHouse,
    );
  }

  void setMode(AppThemeMode mode) {
    state = state.copyWith(mode: mode);
    _prefs.setInt(_keyMode, mode.index);
  }
  
  void setSeason(AppSeason season) {
    state = state.copyWith(season: season);
    _prefs.setInt(_keySeason, season.index);
  }
  
  void setEnvironment(AppEnvironment environment) {
    state = state.copyWith(environment: environment);
    _prefs.setInt(_keyEnvironment, environment.index);
  }

  void setHouse(AppHouse house) {
    state = state.copyWith(house: house);
    _prefs.setInt(_keyHouse, house.index);
  }
  
  void toggleMode() {
    final newMode = state.mode == AppThemeMode.day ? AppThemeMode.night : AppThemeMode.day;
    state = state.copyWith(mode: newMode);
    _prefs.setInt(_keyMode, newMode.index);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});
