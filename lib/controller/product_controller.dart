import 'package:get/get.dart';
import '../data/models/product_model.dart';
import '../data/services/product_service.dart';
import 'dart:async';

class ProductController extends GetxController {
  final ProductService _service = ProductService();
  var products = <ProductModel>[].obs;
  var popularProducts = <ProductModel>[].obs;
  List<ProductModel> _originalPopularProducts = [];
  var isLoading = false.obs;
  @override
  void onInit() {
    fetchPopularProducts();
    super.onInit();
  }

  Future<void> fetchPopularProducts() async {
    try {
      isLoading.value = true;
      final result = await _service.getPopularProducts();
      products.assignAll(result);
    } catch (e) {
      print("Error loading products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllPopularProducts() async {
    try {
      isLoading.value = true;
      final result = await _service.getAllPopularProducts();
      _originalPopularProducts = result;
      popularProducts.assignAll(result);
    } catch (e) {
      print("Error loading popular products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  var categoryProducts = <ProductModel>[].obs;
  List<ProductModel> _originalCategoryProducts = [];
  Future<void> fetchProductsByCategory({required String categoryId}) async {
    if (isLoading.value) return; // tránh double call
    try {
      isLoading.value = true;
      final result = await _service.getProductsByCategory(
        categoryId: categoryId,
      );
      _originalCategoryProducts = result;
      categoryProducts.assignAll(result);
    } catch (e) {
      print("Error loading category products: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void sortPopularProducts(String sortType) {
    List<ProductModel> sorted = List.from(_originalPopularProducts);
    if (sortType == "low_price") {
      sorted.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortType == "high_price") {
      sorted.sort((a, b) => b.price.compareTo(a.price));
    } else {
      sorted.sort((a, b) => a.title.compareTo(b.title));
    }
    popularProducts.assignAll(sorted);
  }

  void sortCategoryProducts(String sortType) {
    List<ProductModel> sortedList = List.from(_originalCategoryProducts);
    if (sortType == "low_price") {
      sortedList.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortType == "high_price") {
      sortedList.sort((a, b) => b.price.compareTo(a.price));
    } else {
      sortedList.sort((a, b) => a.title.compareTo(b.title));
    }
    categoryProducts.assignAll(sortedList);
  }

  var selectedProduct = Rxn<ProductModel>();
  Future<void> fetchProductDetail(String productId) async {
    try {
      isLoading.value = true;
      final result = await _service.getProductById(productId);
      selectedProduct.value = result;
    } catch (e) {
      print("Error loading product detail: $e");
    } finally {
      isLoading.value = false;
    }
  }

  var searchQuery = ''.obs;
  var searchResults = <ProductModel>[].obs;
  void searchProducts(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    final lowerQuery = query.toLowerCase().trim();
    final results = products.where((product) {
      /// ignore inactive / deleted
      if (!product.isActive || product.isDeleted) return false;

      /// match title
      final matchTitle = product.lowerTitle.contains(lowerQuery);

      /// match brand
      final matchBrand =
          product.brandName?.toLowerCase().contains(lowerQuery) ?? false;

      /// match tags
      final matchTags = product.tags.any(
        (tag) => tag.toLowerCase().contains(lowerQuery),
      );
      return matchTitle || matchBrand || matchTags;
    }).toList();

    /// ===== SORT (RANKING) =====
    results.sort((a, b) {
      /// ưu tiên match ở đầu title
      final aStarts = a.lowerTitle.startsWith(lowerQuery);
      final bStarts = b.lowerTitle.startsWith(lowerQuery);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      /// ưu tiên sản phẩm bán nhiều
      return b.soldQuantity.compareTo(a.soldQuantity);
    });
    searchResults.assignAll(results);
  }

  Timer? _debounce;
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchProducts(query);
    });
  }
}
