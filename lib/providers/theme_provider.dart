import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/theme.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePreferenceKey = 'theme_preference';
  static const String _themeLightValue = 'light';
  static const String _themeDarkValue = 'dark';
  static const String _themeKidsValue = 'kids';
  
  ThemeData _currentTheme = AppTheme.kidTheme();
  String _currentThemeType = _themeKidsValue;
  
  ThemeData get currentTheme => _currentTheme;
  String get currentThemeType => _currentThemeType;
  
  bool get isLightTheme => _currentThemeType == _themeLightValue;
  bool get isDarkTheme => _currentThemeType == _themeDarkValue;
  bool get isKidsTheme => _currentThemeType == _themeKidsValue;
  
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  ThemeProvider() {
    _loadThemePreference();
    _loadThemeMode();
  }
  
  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeType = prefs.getString(_themePreferenceKey) ?? _themeKidsValue;
      _setTheme(themeType);
    } catch (e) {
      // Default to kids theme if there's an error
      _setTheme(_themeKidsValue);
    }
  }
  
  // Set theme based on theme type
  void _setTheme(String themeType) {
    switch (themeType) {
      case _themeLightValue:
        _currentTheme = AppTheme.lightTheme();
        _currentThemeType = _themeLightValue;
        break;
      case _themeDarkValue:
        _currentTheme = AppTheme.darkTheme();
        _currentThemeType = _themeDarkValue;
        break;
      case _themeKidsValue:
      default:
        _currentTheme = AppTheme.kidTheme();
        _currentThemeType = _themeKidsValue;
        break;
    }
    notifyListeners();
  }
  
  // Set light theme
  Future<void> setLightTheme() async {
    await _saveThemePreference(_themeLightValue);
    _setTheme(_themeLightValue);
  }
  
  // Set dark theme
  Future<void> setDarkTheme() async {
    await _saveThemePreference(_themeDarkValue);
    _setTheme(_themeDarkValue);
  }
  
  // Set kids theme
  Future<void> setKidsTheme() async {
    await _saveThemePreference(_themeKidsValue);
    _setTheme(_themeKidsValue);
  }
  
  // Toggle between themes
  Future<void> toggleTheme() async {
    switch (_currentThemeType) {
      case _themeLightValue:
        await setDarkTheme();
        break;
      case _themeDarkValue:
        await setKidsTheme();
        break;
      case _themeKidsValue:
      default:
        await setLightTheme();
        break;
    }
  }
  
  // Save theme preference
  Future<void> _saveThemePreference(String themeType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePreferenceKey, themeType);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }
  
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  
  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    
    notifyListeners();
  }
} 