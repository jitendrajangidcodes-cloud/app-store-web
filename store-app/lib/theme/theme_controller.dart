import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mirrors the site's theme toggle: follow the system by default, but remember
// an explicit choice across launches.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  static const _key = "theme_mode";

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(_key)) {
      case "light":
        value = ThemeMode.light;
      case "dark":
        value = ThemeMode.dark;
      default:
        value = ThemeMode.system;
    }
  }

  Future<void> toggle(Brightness current) async {
    value = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value == ThemeMode.light ? "light" : "dark");
  }
}
