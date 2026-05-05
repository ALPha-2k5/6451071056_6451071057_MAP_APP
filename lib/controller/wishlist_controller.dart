import 'package:thuc_hanh/controller/login_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/product_model.dart';

class WishlistController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  String? get uid => _authController.currentUser?.id;
  RxSet<String> wishlistIds = <String>{}.obs;
  RxList<ProductModel> items = <ProductModel>[].obs;

  /// LOAD wishlist
  Future<void> loadWishlist() async {
    if (uid == null) return;
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .get();
    wishlistIds.clear();
    items.clear();
    for (var doc in snapshot.docs) {
      final productId = doc.id;
      wishlistIds.add(productId);
      final productDoc =
          await _firestore.collection('products').doc(productId).get();
      if (productDoc.exists) {
        items.add(ProductModel.fromSnapshot(productDoc, null));
      }
    }
    update();
  }

  /// CHECK
  bool isInWishlist(String productId) {
    return wishlistIds.contains(productId);
  }

  /// TOGGLE
  Future<void> toggleWishlist(ProductModel product) async {
    if (uid == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(product.id);
    if (wishlistIds.contains(product.id)) {
      await docRef.delete();
      wishlistIds.remove(product.id);
    } else {
      await docRef.set({'productId': product.id});
      wishlistIds.add(product.id);
    }
    update();
  }

  /// REMOVE riêng
  Future<void> removeItem(String productId) async {
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .delete();
    wishlistIds.remove(productId);
    items.removeWhere((e) => e.id == productId);
    update();
  }
}
