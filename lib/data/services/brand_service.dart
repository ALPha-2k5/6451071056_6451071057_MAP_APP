import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/brand_model.dart';

class BrandService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= LẤY TẤT CẢ BRAND NỔI BẬT (isFeatured = true) =================
  Future<List<BrandModel>> getAllFeaturedBrands() async {
    final snapshot = await _db
        .collection('brands')
        .where('isActive', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
  }

  // ================= LẤY TẤT CẢ BRAND ĐANG HOẠT ĐỘNG =================
  Future<List<BrandModel>> getAllBrands() async {
    final snapshot = await _db
        .collection('brands')
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
  }

  // ================= LẤY BRAND THEO ID =================
  Future<BrandModel?> getBrandById(String brandId) async {
    final doc = await _db.collection('brands').doc(brandId).get();
    if (!doc.exists) return null;
    return BrandModel.fromSnapshot(doc);
  }

  // ================= LẤY BRAND THEO CATEGORY =================
  // Lấy danh sách brand có sản phẩm thuộc category chỉ định
  Future<List<BrandModel>> getBrandsByCategory(String categoryId) async {
    // Lấy danh sách brandId từ collection products theo categoryId
    final productsSnapshot = await _db
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('categoryIds', arrayContains: categoryId)
        .get();

    final brandIds = productsSnapshot.docs
        .map((doc) => doc.data()['brandId'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .toSet()
        .cast<String>()
        .toList();

    if (brandIds.isEmpty) return [];

    // Firestore giới hạn whereIn tối đa 10 phần tử
    final List<BrandModel> brands = [];
    for (int i = 0; i < brandIds.length; i += 10) {
      final chunk = brandIds.sublist(
        i,
        i + 10 > brandIds.length ? brandIds.length : i + 10,
      );
      final brandSnapshot = await _db
          .collection('brands')
          .where(FieldPath.documentId, whereIn: chunk)
          .where('isActive', isEqualTo: true)
          .get();
      brands.addAll(
        brandSnapshot.docs.map((doc) => BrandModel.fromSnapshot(doc)),
      );
    }
    return brands;
  }

  // ================= CẬP NHẬT SỐ LƯỢNG SẢN PHẨM CỦA BRAND =================
  Future<void> updateProductsCount(String brandId, int count) async {
    await _db.collection('brands').doc(brandId).update({
      'productsCount': count,
    });
  }
}
