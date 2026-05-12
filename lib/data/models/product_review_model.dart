import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final String title;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final double rating;
  final String reviewText;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isApproved;
  ReviewModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.userId,
    required this.userName,
    required this.title,
    this.userProfileImage,
    required this.rating,
    required this.reviewText,
    required this.mediaUrls,
    required this.createdAt,
    required this.updatedAt,
    required this.isApproved,
  });
  factory ReviewModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      productId: data['productId'],
      productName: data['productName'],
      productImage: data['productImage'],
      userId: data['userId'],
      userName: data['userName'],
      title: data['title'],
      userProfileImage: data['userProfileImage'],
      rating: (data['rating'] ?? 0).toDouble(),
      reviewText: data['reviewText'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isApproved: data['isApproved'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'rating': rating,
      'reviewText': reviewText,
      'mediaUrls': mediaUrls,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isApproved': isApproved,
    };
  }
}
