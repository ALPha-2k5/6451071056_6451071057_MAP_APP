import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../controller/settings_controller.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final SettingsController settingsController = Get.put(SettingsController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        title: 'Flutter E-Commerce',
        debugShowCheckedModeBanner: false,
// LANGUAGE
        locale: settingsController.locale.value,
// THEME
        themeMode: settingsController.themeMode.value,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          canvasColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
          ),
        ),
        darkTheme: ThemeData.dark(),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      );
    });
  }
}
