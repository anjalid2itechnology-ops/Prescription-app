import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class AccentController {
  static const List<Color> presets = [
    Color(0xFF0F766E),
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFEA580C),
    Color(0xFFDB2777),
    Color(0xFF15803D),
  ];

  static final ValueNotifier<Color> color = ValueNotifier(presets[0]);
  static const _prefsKey = "accent_color_v1";

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_prefsKey);
    if (saved != null) color.value = Color(saved);
  }

  static Future<void> setColor(Color c) async {
    color.value = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, c.value);
  }
}
