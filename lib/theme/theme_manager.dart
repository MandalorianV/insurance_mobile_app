import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_changer.dart';
import 'theme_dark.dart';
import 'theme_light.dart';

enum ThemeEnum { dark, light }

class ThemeManager extends ChangeNotifier implements IThemeManager {
  static ThemeManager? _instance;
  static ThemeManager get instance {
    _instance ??= ThemeManager._init();
    return _instance!;
  }

  ThemeManager._init();

  static const _prefKey = 'selected_theme';

  @override
  ThemeData currentTheme = ThemeEnum.light.generateTheme;

  @override
  ThemeEnum currentThemeEnum = ThemeEnum.light;

  // ── Başlangıçta kaydedilmiş temayı yükle ──────────────────
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    final theme = saved == 'dark' ? ThemeEnum.dark : ThemeEnum.light;
    currentTheme = theme.generateTheme;
    currentThemeEnum = theme;
    notifyListeners();
  }

  // ── Temayı değiştir ve kaydet ──────────────────────────────
  @override
  void changeTheme(ThemeEnum newTheme) async {
    if (newTheme == currentThemeEnum) return;
    currentTheme = newTheme.generateTheme;
    currentThemeEnum = newTheme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newTheme.name);
  }
}

extension ThemeEnumExtension on ThemeEnum {
  ThemeData get generateTheme {
    switch (this) {
      case ThemeEnum.light:
        return ThemeLight.instance.theme!;
      case ThemeEnum.dark:
        return ThemeDark.instance.theme!;
    }
  }
}
