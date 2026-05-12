import 'package:get/get.dart';
import '../data/models/brand_model.dart';
import '../data/models/product_model.dart';
import '../data/services/brand_service.dart';
import '../data/services/product_service.dart';
class AllBrandController extends GetxController {
final BrandService _brandService = BrandService();
final ProductService _productService = ProductService();
var isLoading = false.obs;
/// ================= BRAND LIST =================
var brands = <BrandModel>[].obs;
/// ================= BRAND DETAIL PRODUCTS =================
var brandProducts = <ProductModel>[].obs;
List<ProductModel> _originalBrandProducts = [];
@override
void onInit() {
super.onInit();
fetchBrands();
}
/// ================= FETCH BRANDS =================
Future<void> fetchBrands() async {
try {
isLoading.value = true;
final result = await _brandService.getAllFeaturedBrands();
brands.assignAll(result);
} catch (e) {
print("Error loading brands: $e");
} finally {
isLoading.value = false;
}
}
/// ================= FETCH PRODUCTS BY BRAND =================
Future<void> fetchProductsByBrand(String brandId) async {
try {
isLoading.value = true;
final result = await _productService.getProductsByBrand(brandId:
brandId);
_originalBrandProducts = result;
brandProducts.assignAll(result);
} catch (e) {
print("Error loading brand products: $e");
} finally {
isLoading.value = false;
}
}
/// ================= SORT =================
var selectedSort = "name".obs;
void sortBrandProducts(String sortType) {
selectedSort.value = sortType;
List<ProductModel> sorted = List.from(_originalBrandProducts);
if (sortType == "low_price") {
sorted.sort((a, b) => a.price.compareTo(b.price));
} else if (sortType == "high_price") {
sorted.sort((a, b) => b.price.compareTo(a.price));
} else {
sorted.sort(
(a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
);
}
brandProducts.assignAll(sorted);
}
}