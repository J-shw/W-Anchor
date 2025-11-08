import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:w_anchor/utils/constants.dart';

class SettingsProvider with ChangeNotifier {

  SharedPreferences? _prefs;
  bool _isLoading = true;

  static const double _defaultAlarmRadius = 30.0;
  static const AppTheme _defaultTheme = AppTheme.system;

  double _alarmRadius = _defaultAlarmRadius;
  AppTheme _theme = _defaultTheme;

  double get alarmRadius => _alarmRadius;
  AppTheme get theme => _theme;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _alarmRadius = _prefs?.getDouble(kAlarmRadius) ?? _defaultAlarmRadius;
    final themeIndex = _prefs?.getInt(kTheme) ?? _defaultTheme.index;
    _theme = AppTheme.values[themeIndex];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setAlarmRadius(double radius) async {
    if (_prefs == null) return;

    await _prefs!.setDouble(kAlarmRadius, radius);
    _alarmRadius = radius;
    notifyListeners();
  }

  Future<void> setTheme(AppTheme newTheme) async {
    if (_prefs == null) return;

    await _prefs!.setInt(kTheme, newTheme.index);
    _theme = newTheme;
    notifyListeners();
  }
}