import 'package:cloud_firestore/cloud_firestore.dart';
class BrandModel {
final String id;
final String name;
final String imageUrl;
final bool isFeatured;
final bool isActive;
final int productsCount;
BrandModel({
required this.id,
required this.name,
required this.imageUrl,
required this.isFeatured,
required this.isActive,
required this.productsCount,
});
factory BrandModel.fromSnapshot(DocumentSnapshot doc) {
final data = doc.data() as Map<String, dynamic>;
return BrandModel(
id: doc.id,
name: data['name'] ?? '',
imageUrl: data['imageURL'] ?? '',
isFeatured: data['isFeatured'] ?? false,
isActive: data['isActive'] ?? false,
productsCount: data['productsCount'] ?? 0,
);
}
BrandModel copyWith({int? productsCount}) {
return BrandModel(
id: id,
name: name,
imageUrl: imageUrl,
isFeatured: isFeatured,
isActive: isActive,
productsCount: productsCount ?? this.productsCount,);}}