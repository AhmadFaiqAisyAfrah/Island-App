import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode {
  day,
  night,
}

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.day);

  void setMode(AppThemeMode mode) {
    state = mode;
  }
  
  void toggle() {
    state = state == AppThemeMode.day ? AppThemeMode.night : AppThemeMode.day;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});
