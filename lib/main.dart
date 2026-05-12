import 'package:thuc_hanh/controller/cart_controller.dart';
import 'package:thuc_hanh/controller/notification_controller.dart';
import 'package:thuc_hanh/controller/order_controller.dart';
import 'package:thuc_hanh/controller/wishlist_controller.dart';
import 'package:thuc_hanh/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'controller/login_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Tắt persistence để tránh lỗi "INTERNAL ASSERTION FAILED" trên Web
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  Get.put(AuthController());
  Get.put(NotificationController());
  Get.put(CartController());
  Get.put(OrderController());
  Get.put(WishlistController());
  Get.put(SettingsController());
  runApp(MyApp());
}