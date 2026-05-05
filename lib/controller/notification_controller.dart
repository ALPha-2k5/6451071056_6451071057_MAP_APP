import 'package:get/get.dart';
import '../data/models/notification_model.dart';
import '../data/services/notification_service.dart';
import 'login_controller.dart';

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  late AuthController authController;
  @override
  void onInit() {
    super.onInit();
    authController = Get.find<AuthController>();
    final user = authController.currentUser;
    if (user != null) {
      _service.getUserNotifications(user.id).listen((data) {
        notifications.value = data;

        ///tính số chưa đọc
        unreadCount.value = data.where((n) => n.isRead == false).length;
      });
    }
  }

  /// đánh dấu đã đọc
  Future<void> markAsRead(NotificationModel noti) async {
    if (noti.isRead) return;
    await _service.markAsRead(noti.id);

    /// reload lại list từ firestore
    notifications.value = notifications.map((n) {
      if (n.id == noti.id) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          orderId: n.orderId,
          orderStatus: n.orderStatus,
          message: n.message,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }
}
