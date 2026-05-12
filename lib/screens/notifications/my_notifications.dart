import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/order_model.dart';
import '../../controller/notification_controller.dart';
import '../order/ordered_detail_screen.dart';

class MyNotificationScreen extends StatelessWidget {
  MyNotificationScreen({super.key});

  final NotificationController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Thông báo của tôi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.markAllAsRead(),
            child: const Text("Đọc hết", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const _EmptyNotificationView();
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: controller.notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            final noti = controller.notifications[index];
            return _NotificationTile(
              noti: noti,
              onTap: () => _handleNotificationClick(context, noti),
            );
          },
        );
      }),
    );
  }

  /// Logic xử lý khi click vào thông báo
  Future<void> _handleNotificationClick(BuildContext context, dynamic noti) async {
    // 1. Đánh dấu đã đọc
    await controller.markAsRead(noti);

    // 2. Hiển thị loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .where('id', isEqualTo: noti.orderId)
          .limit(1)
          .get();

      Get.back(); // Đóng loading

      if (orderDoc.docs.isNotEmpty) {
        final data = Map<String, dynamic>.from(orderDoc.docs.first.data());
        data['docId'] = orderDoc.docs.first.id;
        final order = OrderModel.fromJson(data);
        Get.to(() => OrderDetailScreen(order: order));
      } else {
        Get.snackbar("Lỗi", "Không tìm thấy thông tin đơn hàng",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.back(); // Đóng loading khi lỗi
      Get.snackbar("Lỗi", "Đã xảy ra lỗi: $e",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

/// Widget Item thông báo
class _NotificationTile extends StatelessWidget {
  final dynamic noti;
  final VoidCallback onTap;

  const _NotificationTile({required this.noti, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = _getStatusStyle(noti.message);
    final timeString = "${noti.createdAt.hour.toString().padLeft(2, '0')}:${noti.createdAt.minute.toString().padLeft(2, '0')} - ${noti.createdAt.day}/${noti.createdAt.month}/${noti.createdAt.year}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: noti.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Thanh màu chỉ thị
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: noti.isRead ? Colors.transparent : style['color'],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: ListTile(
                onTap: onTap,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: style['color'].withOpacity(0.1),
                  child: Icon(style['icon'], color: style['color'], size: 20),
                ),
                title: Text(
                  noti.message,
                  style: TextStyle(
                    fontWeight: noti.isRead ? FontWeight.normal : FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(timeString, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                trailing: !noti.isRead
                    ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusStyle(String message) {
    String msg = message.toLowerCase();
    if (msg.contains('created')) return {'icon': Icons.add_shopping_cart, 'color': Colors.blue};
    if (msg.contains('pending')) return {'icon': Icons.hourglass_top_rounded, 'color': Colors.orange};
    if (msg.contains('processing')) return {'icon': Icons.sync, 'color': Colors.amber};
    if (msg.contains('shipped')) return {'icon': Icons.local_shipping_rounded, 'color': Colors.purple};
    if (msg.contains('delivered')) return {'icon': Icons.check_circle_rounded, 'color': Colors.green};
    if (msg.contains('cancelled')) return {'icon': Icons.cancel_rounded, 'color': Colors.red};
    return {'icon': Icons.notifications_active_rounded, 'color': Colors.blueGrey};
  }
}

/// Widget khi không có thông báo
class _EmptyNotificationView extends StatelessWidget {
  const _EmptyNotificationView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Chưa có thông báo nào",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text("Cập nhật đơn hàng sẽ xuất hiện tại đây", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}