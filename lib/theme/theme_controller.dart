import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Global theme mode controller — lets any screen toggle dark/light,
/// and persists the choice across app restarts.
class ThemeController {
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);
  static const _prefsKey = "theme_mode_v1";

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == "dark") mode.value = ThemeMode.dark;
    if (saved == "light") mode.value = ThemeMode.light;
  }

  static Future<void> toggle() async {
    mode.value = mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.value == ThemeMode.dark ? "dark" : "light");
  }
}
