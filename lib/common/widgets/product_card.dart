import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thuc_hanh/controller/cart_controller.dart';
import 'package:thuc_hanh/controller/login_controller.dart';
import 'package:thuc_hanh/controller/wishlist_controller.dart';
import '../../data/models/product_model.dart';
import '../../screens/product/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Tìm các Controller
    final cartController = Get.find<CartController>();
    final wishlistController = Get.find<WishlistController>();
    final authController = Get.find<AuthController>();

    // Logic kiểm tra trạng thái
    final bool isOutOfStock = product.isOutOfStock == true || product.stock <= 0;
    final bool hasDiscount = product.salePrice != null && product.salePrice! > 0;
    
    // Tính toán giá gốc dựa trên % giảm giá (nếu salePrice là số phần trăm)
    final double originalPrice = hasDiscount 
        ? product.price / (1 - (product.salePrice! / 100)) 
        : product.price;

    return InkWell(
      onTap: () => Get.to(() => ProductDetailScreen(productId: product.id)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- PHẦN HÌNH ẢNH ---
            Stack(
              children: [
                // Ảnh sản phẩm
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.network(
                      product.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[100],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                // Overlay Hết hàng
                if (isOutOfStock) _buildOutOfStockOverlay(),

                // Badge Giảm giá
                if (hasDiscount && !isOutOfStock) _buildDiscountBadge(product.salePrice!),

                // Nút Yêu thích (Favorite)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Obx(() {
                    final isFav = wishlistController.isInWishlist(product.id);
                    return IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFav ? Colors.red : Colors.grey[400],
                      ),
                      onPressed: () {
                        if (authController.currentUser == null) {
                          _showLoginDialog();
                        } else {
                          wishlistController.toggleWishlist(product);
                        }
                      },
                    );
                  }),
                ),
              ],
            ),

            /// --- PHẦN NỘI DUNG ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Name
                    Text(
                      (product.brandName ?? 'BRAND').toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Title
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
                    ),
                    
                    const Spacer(),

                    // Giá sản phẩm
                    _buildPriceRow(hasDiscount, product.price, originalPrice),

                    const SizedBox(height: 6),

                    // Rating & Cart Status
                    _buildBottomInfo(cartController),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Overlay khi hết hàng
  Widget _buildOutOfStockOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
            child: const Text(
              "HẾT HÀNG",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }

  // Tag giảm giá
  Widget _buildDiscountBadge(double discount) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(6)),
        child: Text(
          "-${discount.toStringAsFixed(0)}%",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ),
    );
  }

  // Dòng hiển thị giá
  Widget _buildPriceRow(bool hasDiscount, double currentPrice, double originalPrice) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          "\$${currentPrice.toStringAsFixed(0)}",
          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 4),
          Text(
            "\$${originalPrice.toStringAsFixed(0)}",
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[400],
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  // Dòng thông tin đánh giá và icon giỏ hàng
  Widget _buildBottomInfo(CartController cartController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.star, size: 14, color: Colors.orange),
            const SizedBox(width: 2),
            Text(
              "${product.rating}",
              style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Obx(() {
          final isAdded = cartController.isInCart(product.id, null);
          return isAdded
              ? const Icon(Icons.check_circle_rounded, size: 18, color: Colors.green)
              : const SizedBox.shrink();
        }),
      ],
    );
  }

  // Dialog thông báo đăng nhập
  void _showLoginDialog() {
    Get.defaultDialog(
      title: "Yêu cầu đăng nhập",
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      middleText: "Vui lòng đăng nhập để lưu sản phẩm yêu thích.",
      textConfirm: "Đăng nhập",
      textCancel: "Để sau",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      onConfirm: () {
        Get.back();
        Get.toNamed('/login');
      },
    );
  }
}