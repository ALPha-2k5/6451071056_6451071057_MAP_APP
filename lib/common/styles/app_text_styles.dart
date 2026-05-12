import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/settings_controller.dart';
import 'app_colors.dart';

class AppTextStyle {
  static double get scale {
    final controller = Get.find<SettingsController>();
    switch (controller.fontSize.value) {
      case 'small':
        return 0.9;
      case 'large':
        return 1.2;
      default:
        return 1.0;
    }
  }

  static TextStyle title = TextStyle(
    fontSize: 22 * scale,
    fontWeight: FontWeight.bold,
    color: AppColors.dark,
  );
  static TextStyle subtitle = TextStyle(
    fontSize: 14 * scale,
    color: AppColors.grey,
  );
  static TextStyle whiteTitle = TextStyle(
    fontSize: 20 * scale,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle whiteSubtitle = TextStyle(
    fontSize: 14 * scale,
    color: Colors.white70,
  );
}
