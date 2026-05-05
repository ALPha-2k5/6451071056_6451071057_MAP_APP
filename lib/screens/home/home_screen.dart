import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thuc_hanh/controller/cart_controller.dart';
import 'package:thuc_hanh/controller/category_controller.dart';
import 'package:thuc_hanh/controller/login_controller.dart';
import 'package:thuc_hanh/controller/notification_controller.dart';
import 'package:thuc_hanh/controller/product_controller.dart';
import '../../common/widgets/home_banner_slider.dart';
import '../../common/widgets/product_card.dart';
import '../cart/cart_overview_screen.dart';
import '../notifications/my_notifications.dart';
import '../product/popular_product_screen.dart';
import '/screens/product/product_by_subcategory_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Khởi tạo/Tìm các Controller
  final categoryController = Get.put(CategoryController());
  final productController = Get.put(ProductController());
  final cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final user = authController.currentUser;
        final String fullName = user != null ? '${user.firstName} ${user.lastName}' : 'Guest User';

        return Scaffold(
          body: Column(
            children: [
              /// --- TOP BLUE HEADER ---
              _buildHeader(context, authController, fullName),

              /// --- MAIN CONTENT ---
              Expanded(
                child: Obx(() {
                  // Chế độ tìm kiếm
                  if (productController.searchQuery.isNotEmpty) {
                    return _buildSearchResults();
                  }
                  // Chế độ bình thường
                  return _buildNormalContent();
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Header chứa Thông tin User, Icons và Search Bar
  Widget _buildHeader(BuildContext context, AuthController authController, String fullName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Good day for shopping', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                      fullName,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Notification Icon
                if (authController.currentUser != null) _buildNotificationIcon(context),
                
                // Cart Icon
                _buildCartIcon(context),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            TextField(
              onChanged: (value) => productController.onSearchChanged(value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm trong cửa hàng',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Danh mục phổ biến', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Danh sách Category
            _buildCategoryList(),
          ],
        ),
      ),
    );
  }

  /// Widget Icon thông báo với Badge số lượng
  Widget _buildNotificationIcon(BuildContext context) {
    final notificationController = Get.find<NotificationController>();
    return Obx(() => Stack(
          children: [
            IconButton(
              onPressed: () => Get.to(() => MyNotificationScreen()),
              icon: const Icon(Icons.notifications, color: Colors.white),
            ),
            if (notificationController.unreadCount.value > 0)
              Positioned(
                right: 6,
                top: 6,
                child: _Badge(count: notificationController.unreadCount.value),
              ),
          ],
        ));
  }

  /// Widget Icon giỏ hàng với Badge số lượng
  Widget _buildCartIcon(BuildContext context) {
    return Obx(() => Stack(
          children: [
            IconButton(
              onPressed: () => Get.to(() => const CartOverviewScreen()),
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
            ),
            if (cartController.totalItems > 0)
              Positioned(
                right: 6,
                top: 6,
                child: _Badge(count: cartController.totalItems),
              ),
          ],
        ));
  }

  /// Danh sách Category cuộn ngang
  Widget _buildCategoryList() {
    return SizedBox(
      height: 90,
      child: Obx(() {
        if (categoryController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categoryController.categories.length,
          itemBuilder: (context, index) {
            final category = categoryController.categories[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => Get.to(() => ProductBySubCategoryScreen(
                      categoryId: category.id,
                      categoryName: category.name,
                    )),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      backgroundImage: NetworkImage(category.imageURL),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.name,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// Nội dung khi tìm kiếm
  Widget _buildSearchResults() {
    if (productController.searchResults.isEmpty) {
      return const Center(child: Text("Không tìm thấy sản phẩm"));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: productController.searchResults.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) => ProductCard(product: productController.searchResults[index]),
    );
  }

  /// Nội dung hiển thị bình thường (Banner + Sản phẩm phổ biến)
  Widget _buildNormalContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeBannerSlider(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sản phẩm phổ biến', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Get.to(() => const PopularProductScreen()),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (productController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return GridView.builder(
              itemCount: productController.products.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, index) => ProductCard(product: productController.products[index]),
            );
          }),
        ],
      ),
    );
  }
}

/// Widget phụ trợ hiển thị chấm đỏ số lượng (Badge)
class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}