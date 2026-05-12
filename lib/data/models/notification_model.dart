import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String orderId;
  final String orderStatus;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  NotificationModel({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.orderStatus,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'],
      orderId: data['orderId'],
      orderStatus: data['orderStatus'],
      message: data['message'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
