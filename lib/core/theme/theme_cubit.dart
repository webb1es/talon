import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_colors.dart';
import 'app_theme.dart';

class ThemeState {
  final AppThemeType themeType;
  final ThemeMode themeMode;

  const ThemeState({
    this.themeType = AppThemeType.predator,
    this.themeMode = ThemeMode.light,
  });

  bool get isDark => themeMode == ThemeMode.dark;

  AppColors get colors {
    switch (themeType) {
      case AppThemeType.predator:
        return isDark ? AppColors.predatorDark : AppColors.predatorLight;
      case AppThemeType.precision:
        return isDark ? AppColors.precisionDark : AppColors.precisionLight;
      case AppThemeType.strike:
        return isDark ? AppColors.strikeDark : AppColors.strikeLight;
    }
  }

  ThemeData get themeData {
    switch (themeType) {
      case AppThemeType.predator:
        return isDark ? AppTheme.predatorDark : AppTheme.predatorLight;
      case AppThemeType.precision:
        return isDark ? AppTheme.precisionDark : AppTheme.precisionLight;
      case AppThemeType.strike:
        return isDark ? AppTheme.strikeDark : AppTheme.strikeLight;
    }
  }

  ThemeState copyWith({AppThemeType? themeType, ThemeMode? themeMode}) {
    return ThemeState(
      themeType: themeType ?? this.themeType,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  void setTheme(AppThemeType type) {
    emit(state.copyWith(themeType: type));
  }

  void toggleMode() {
    emit(state.copyWith(
      themeMode: state.isDark ? ThemeMode.light : ThemeMode.dark,
    ));
  }

  void setMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }
}
