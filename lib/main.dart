import 'package:thuc_hanh/controller/cart_controller.dart';
import 'package:thuc_hanh/controller/notification_controller.dart';
import 'package:thuc_hanh/controller/order_controller.dart';
import 'package:thuc_hanh/controller/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'controller/login_controller.dart';
void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
Get.put(AuthController());
Get.put(CartController());
Get.put(OrderController());
Get.put(WishlistController());
Get.put(NotificationController());
runApp(MyApp());
}