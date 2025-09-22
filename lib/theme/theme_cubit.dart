import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/theme/theme_state.dart';
import 'package:task_manager/utils/constants.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences prefs;

  ThemeCubit(this.prefs) : super(const ThemeState(ThemeMode.system)) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeIndex = prefs.getInt(Constants.themeKey);
    if (themeIndex != null) {
      final themeMode = ThemeMode.values[themeIndex];
      emit(ThemeState(themeMode));
    }
  }

  void setTheme(ThemeMode themeMode) {
    prefs.setInt(Constants.themeKey, themeMode.index);
    emit(ThemeState(themeMode));
  }
}
