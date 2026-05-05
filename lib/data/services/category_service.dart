import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<List<CategoryModel>> getAllCategories() async {
    final snapshot = await _db
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .orderBy('priority')
        .limit(10)
        .get();
    return snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
  }
}
