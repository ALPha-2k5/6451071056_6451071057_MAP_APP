import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductType { simple, variable }

class ProductAttribute {
  final String attributeId;
  final String name;
  final List<String> values;
  ProductAttribute({
    required this.attributeId,
    required this.name,
    required this.values,
  });
  factory ProductAttribute.fromMap(Map<String, dynamic> map) {
    return ProductAttribute(
      attributeId: map['attributeId'] ?? '',
      name: map['name'] ?? '',
      values: List<String>.from(map['values'] ?? []),
    );
  }
}

class ProductModel {
  final String id;
  final String title;
  final String lowerTitle;
  final String? description;
  final double price;
  final double? salePrice;
  final String thumbnail;
  final List<String> images;
  final String? brandId;
  final String? brandName;
  final List<String> categoryIds;
  final List<String> tags;
  final List<ProductAttribute> attributes;
  final int stock;
  final String? sku;
  final ProductType productType;
  final bool isFeatured;
  final bool isActive;
  final bool isDraft;
  final bool isDeleted;
  final bool isRecommended;
  final bool? onSale;
  final bool? isOutOfStock;
  final double rating;
  final int ratingCount;
  final int reviewsCount;
  final int oneStarCount;
  final int twoStarCount;
  final int threeStarCount;
  final int fourStarCount;
  final int fiveStarCount;
  final int soldQuantity;
  final int views;
  final int likes;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? saleStartDate;
  final Timestamp? saleEndDate;
  ProductModel({
    required this.id,
    required this.title,
    required this.lowerTitle,
    this.description,
    required this.price,
    this.salePrice,
    required this.thumbnail,
    required this.images,
    this.brandId,
    this.brandName,
    required this.categoryIds,
    required this.tags,
    required this.attributes,
    required this.stock,
    this.sku,
    required this.productType,
    this.isFeatured = false,
    this.isActive = true,
    this.isDraft = false,
    this.isDeleted = false,
    this.isRecommended = false,
    this.onSale,
    this.isOutOfStock,
    this.rating = 0,
    this.ratingCount = 0,
    this.reviewsCount = 0,
    this.oneStarCount = 0,
    this.twoStarCount = 0,
    this.threeStarCount = 0,
    this.fourStarCount = 0,
    this.fiveStarCount = 0,
    this.soldQuantity = 0,
    this.views = 0,
    this.likes = 0,
    this.createdAt,
    this.updatedAt,
    this.saleStartDate,
    this.saleEndDate,
  });
  factory ProductModel.fromSnapshot(DocumentSnapshot doc, String? brandName) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      title: data['title'] ?? '',
      lowerTitle: data['lowerTitle'] ?? '',
      description: data['description'],
      price: (data['price'] ?? 0).toDouble(),
      salePrice:
          data['salePrice'] != null ? (data['salePrice']).toDouble() : null,
      thumbnail: data['thumbnail'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      brandId: data['brandId'],
      brandName: brandName,
      categoryIds: List<String>.from(data['categoryIds'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      attributes: (data['attributes'] as List<dynamic>?)
              ?.map((e) => ProductAttribute.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      stock: data['stock'] ?? 0,
      sku: data['sku'],
      productType: data['productType'] == 'variable'
          ? ProductType.variable
          : ProductType.simple,
      isFeatured: data['isFeatured'] ?? false,
      isActive: data['isActive'] ?? true,
      isDraft: data['isDraft'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      isRecommended: data['isRecommended'] ?? false,
      onSale: data['onSale'],
      isOutOfStock: data['isOutOfStock'],
      rating: (data['rating'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      reviewsCount: data['reviewsCount'] ?? 0,
      oneStarCount: data['oneStarCount'] ?? 0,
      twoStarCount: data['twoStarCount'] ?? 0,
      threeStarCount: data['threeStarCount'] ?? 0,
      fourStarCount: data['fourStarCount'] ?? 0,
      fiveStarCount: data['fiveStarCount'] ?? 0,
      soldQuantity: data['soldQuantity'] ?? 0,
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      saleStartDate: data['saleStartDate'],
      saleEndDate: data['saleEndDate'],
    );
  }
}
