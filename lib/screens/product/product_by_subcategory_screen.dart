import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/product_controller.dart';
import '../../common/widgets/product_card.dart';

class ProductBySubCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ProductBySubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductBySubCategoryScreen> createState() => _ProductBySubCategoryScreenState();
}

class _ProductBySubCategoryScreenState extends State<ProductBySubCategoryScreen> {
  final ProductController productController = Get.find<ProductController>();

  // Lưu trữ filter đang chọn
  String _selectedFilterKey = 'Name';

  // Map cấu hình filter đồng bộ với hệ thống backend/logic
  final Map<String, String> _filterMap = {
    'Name': 'name',
    'Price: Low to High': 'low_price',
    'Price: High to Low': 'high_price',
  };

  @override
  void initState() {
    super.initState();
    // Gọi API lấy sản phẩm sau khi frame đầu tiên được dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.fetchProductsByCategory(categoryId: widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          /// 1. Dải Filter cuộn ngang
          _buildFilterBar(),

          /// 2. Danh sách sản phẩm (Grid View)
          Expanded(
            child: Obx(() {
              // Trạng thái đang tải
              if (productController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              }

              // Trạng thái danh sách trống
              if (productController.categoryProducts.isEmpty) {
                return _buildEmptyState();
              }

              // Hiển thị Grid sản phẩm
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: productController.categoryProducts.length,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62, // Tăng nhẹ tỉ lệ để tránh tràn text
                ),
                itemBuilder: (context, index) {
                  final product = productController.categoryProducts[index];
                  return ProductCard(product: product);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// App Bar với Gradient đồng bộ
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.categoryName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

  /// Widget dải Filter
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
                    // Thực hiện sắp xếp sản phẩm
                    productController.sortCategoryProducts(_filterMap[filterName]!);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Giao diện khi không có sản phẩm
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Không có sản phẩm nào trong mục này",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}