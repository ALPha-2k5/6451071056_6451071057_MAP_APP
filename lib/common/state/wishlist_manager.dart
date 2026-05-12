import 'package:get/get.dart';
import 'package:thuc_hanh/controller/login_controller.dart';

class WishlistManager {
  static final WishlistManager _instance = WishlistManager._internal();
  factory WishlistManager() {
    return _instance;
  }
  WishlistManager._internal();
// Map<userId, List<Product>>
  final Map<String, List<Map<String, dynamic>>> _userWishlists = {};
  List<Map<String, dynamic>> get items {
    final AuthController authController = Get.find<AuthController>();
    final user = authController.currentUser;
    if (user == null) {
      return [];
    }
    if (_userWishlists[user.id] == null) {
      _userWishlists[user.id] = [];
    }
    return _userWishlists[user.id]!;
  }

  bool isFavorite(String id) {
    final currentItems = items;
    return currentItems.any((element) => element['id'] == id);
  }

  void toggle(Map<String, dynamic> product) {
    final AuthController authController = Get.find<AuthController>();
    final user = authController.currentUser;
    if (user == null) {
      return;
    }
    if (_userWishlists[user.id] == null) {
      _userWishlists[user.id] = [];
    }
    final List<Map<String, dynamic>> userItems = _userWishlists[user.id]!;
    final index = userItems.indexWhere(
      (element) => element['id'] == product['id'],
    );
    if (index >= 0) {
      userItems.removeAt(index);
    } else {
      userItems.add(product);
    }
  }
}
