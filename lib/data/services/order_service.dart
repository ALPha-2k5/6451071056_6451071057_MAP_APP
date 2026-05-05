import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;
  Future<void> createOrder(OrderModel order) async {
    await _db.collection('orders').add({
      'id': order.id,
      'userId': order.userId,
      'total': order.totalAmount,
      'status': order.orderStatus,
      'createdAt': DateTime.now(),
    });
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    final snapshot = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return OrderModel.fromJson({...data, 'docId': doc.id});
    }).toList();
  }

  Future<bool> hasUserPurchasedProduct({
    required String userId,
    required String productId,
  }) async {
    final snapshot = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('orderStatus', isEqualTo: 'delivered') // 🔥 ONLY delivered
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['products'] == null) continue;
      final List products = data['products'];
      for (var item in products) {
        if (item['productId'] == productId) {
          return true;
        }
      }
    }
    return false;
  }
}
