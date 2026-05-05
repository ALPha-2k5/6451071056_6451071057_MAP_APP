import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/product_card.dart';
import '../../controller/product_controller.dart';

class PopularProductScreen extends StatefulWidget {
  const PopularProductScreen({super.key});

  @override
  State<PopularProductScreen> createState() => _PopularProductScreenState();
}

class _PopularProductScreenState extends State<PopularProductScreen> {
  final ProductController productController = Get.find<ProductController>();

  // Biến lưu trữ filter đang chọn
  String _selectedFilterKey = 'Name';

  // Map cấu hình filter: Hiển thị -> Giá trị định danh trong Controller
  final Map<String, String> _filterMap = {
    'Name': 'name',
    'Price: Low to High': 'low_price',
    'Price: High to Low': 'high_price',
    'Newest': 'newest',
  };

  @override
  void initState() {
    super.initState();
    // Gọi API sau khi khung hình đầu tiên được dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.fetchAllPopularProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          /// 1. Thanh Filter cuộn ngang
          _buildFilterBar(),

          /// 2. Danh sách sản phẩm
          Expanded(
            child: Obx(() {
              if (productController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              }

              if (productController.popularProducts.isEmpty) {
                return _buildEmptyState();
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: productController.popularProducts.length,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62, // Nhất quán với ProductCard mới
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: productController.popularProducts[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// App Bar với Gradient đồng bộ toàn app
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Sản phẩm phổ biến',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      elevation: 0,
      foregroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade400],
          ),
        ),
      ),
    );
  }

  /// Widget thanh lọc sản phẩm
  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filterMap.keys.map((filterName) {
            final isSelected = _selectedFilterKey == filterName;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filterName),
                selected: isSelected,
                selectedColor: Colors.blue.shade600,
                backgroundColor: Colors.grey.shade100,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                elevation: 0,
                pressElevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.blue.shade600 : Colors.transparent,
                  ),
                ),
                onSelected: (bool selected) {
                  if (selected && _selectedFilterKey != filterName) {
                    setState(() {
                      _selectedFilterKey = filterName;
                    });
                    // Gọi hàm sắp xếp trong controller
                    productController.sortPopularProducts(_filterMap[filterName]!);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Widget hiển thị khi không có sản phẩm
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Không tìm thấy sản phẩm nào",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}