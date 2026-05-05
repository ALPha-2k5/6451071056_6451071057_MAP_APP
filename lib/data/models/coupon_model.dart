import 'package:cloud_firestore/cloud_firestore.dart';

enum DiscountType { percentage, fixed }

class CouponModel {
  String id;
  String code;
  String description;
  DiscountType discountType;
  double discountValue;
  DateTime? startDate;
  DateTime? endDate;
  int usageLimit;
  int usageCount;
  bool isActive;
  DateTime? createdAt;
  DateTime? updateAt;
  CouponModel({
    required this.id,
    required this.code,
    this.description = '',
    this.discountType = DiscountType.percentage,
    required this.discountValue,
    this.startDate,
    this.endDate,
    this.usageLimit = -1,
    this.usageCount = 0,
    this.isActive = true,
    this.createdAt,
    this.updateAt,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discountType': discountType.name,
      'discountValue': discountValue,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updateAt': updateAt != null ? Timestamp.fromDate(updateAt!) : null,
    };
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'],
      code: json['code'],
      description: json['description'] ?? '',
      discountType: json['discountType'] == 'percentage'
          ? DiscountType.percentage
          : DiscountType.fixed,
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      startDate: json['startDate']?.toDate(),
      endDate: json['endDate']?.toDate(),
      usageLimit: json['usageLimit'] ?? -1,
      usageCount: json['usageCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt']?.toDate(),
      updateAt: json['updateAt']?.toDate(),
    );
  }
}
