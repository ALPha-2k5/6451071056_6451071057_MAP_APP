import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class MyStoreService {
  final _db = FirebaseFirestore.instance;

  /// 1. Featured Brands
  Future<List<BrandModel>> getFeaturedBrands() async {
    final snapshot = await _db
        .collection('brands')
        .where('isActive', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .get();
    return snapshot.docs.map((e) => BrandModel.fromSnapshot(e)).toList();
  }

  /// 2. Categories
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .orderBy('priority')
        .get();
    return snapshot.docs.map((e) => CategoryModel.fromSnapshot(e)).toList();
  }

  /// 3. Brand by Category (N-N table)
  Future<List<String>> getBrandIdsByCategory(String categoryId) async {
    final snapshot = await _db
        .collection('brand_categories')
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((e) => e['brandId'] as String).toList();
  }

  /// 4. Products by category + brand list
  Future<List<ProductModel>> getProductsByCategoryAndBrands(
    String categoryId,
    List<String> brandIds,
  ) async {
    if (brandIds.isEmpty) return [];
    final snapshot = await _db
        .collection('products')
        .where('categoryIds', arrayContains: categoryId)
        .where('brandId', whereIn: brandIds)
        .get();
    return snapshot.docs.map((e) {
      return ProductModel.fromSnapshot(e, null);
    }).toList();
  }
}
