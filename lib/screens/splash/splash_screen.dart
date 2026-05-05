import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(SplashController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/logos/t-store-splash-logo-black.png',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.image_not_supported,
            size: 72,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
