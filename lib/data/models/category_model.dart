import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  String id;
  String name;
  String imageURL;
  bool isActive;
  bool isFeatured;
  int priority;
  DateTime? createdAt;
  DateTime? updatedAt;
  int numberOfProducts;
  int viewCount;
  String createdBy;
  String updatedBy;
  CategoryModel({
    required this.id,
    required this.name,
    required this.imageURL,
    required this.isActive,
    required this.isFeatured,
    required this.priority,
    this.createdAt,
    this.updatedAt,
    required this.numberOfProducts,
    required this.viewCount,
    required this.createdBy,
    required this.updatedBy,
  });
  factory CategoryModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageURL: data['imageURL'] ?? '',
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      priority: data['priority'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      numberOfProducts: data['numberOfProducts'] ?? 0,
      viewCount: data['viewCount'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      updatedBy: data['updatedBy'] ?? '',
    );
  }
}
