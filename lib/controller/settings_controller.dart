import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/preferences_helper.dart';

class SettingsController extends GetxController {
  var themeMode = ThemeMode.system.obs;
  var fontSize = 'medium'.obs;
  var locale = const Locale('vi').obs;
  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
// THEME
    String theme = await PreferencesHelper.getTheme();
    if (theme == 'light') {
      themeMode.value = ThemeMode.light;
    } else if (theme == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.system;
    }
// FONT
    fontSize.value = await PreferencesHelper.getFontSize();
// LANGUAGE
    String lang = await PreferencesHelper.getLanguage();
    locale.value = Locale(lang);
    Get.updateLocale(locale.value);
  }

  void changeTheme(String value) async {
    await PreferencesHelper.setTheme(value);
    if (value == 'light') {
      themeMode.value = ThemeMode.light;
    } else if (value == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.system;
    }
  }

  void changeFontSize(String value) async {
    await PreferencesHelper.setFontSize(value);
    fontSize.value = value;
  }

  void changeLanguage(String value) async {
    await PreferencesHelper.setLanguage(value);
    locale.value = Locale(value);
    Get.updateLocale(locale.value);
  }
}
