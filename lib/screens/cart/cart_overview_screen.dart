import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thuc_hanh/controller/login_controller.dart';
import 'package:thuc_hanh/screens/auth/login_screen.dart';
import '../../controller/cart_controller.dart';
import '../../data/models/cart_item_model.dart';
import '../order/order_overview_screen.dart';

class CartOverviewScreen extends StatelessWidget {
  const CartOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Danh sách sản phẩm
          Expanded(
            child: Obx(() {
              if (cartController.cartItems.isEmpty) {
                return const _EmptyCartView();
              }
              return ListView.builder(
                itemCount: cartController.cartItems.length,
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = cartController.cartItems[index];
                  return _CartItemTile(
                    item: item,
                    onIncrease: () => cartController.increaseQty(item),
                    onDecrease: () => cartController.decreaseQty(item),
                    onRemove: () => cartController.removeItem(item),
                  );
                },
              );
            }),
          ),

          // Thanh thanh toán
          _BottomCheckoutBar(cartController: cartController),
        ],
      ),
    );
  }

  /// AppBar tùy chỉnh
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Giỏ hàng của bạn',
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
}

/// Widget hiển thị khi giỏ hàng trống
class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Giỏ hàng của bạn đang trống",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Tiếp tục mua sắm"),
          ),
        ],
      ),
    );
  }
}

/// Widget Thanh thanh toán phía dưới
class _BottomCheckoutBar extends StatelessWidget {
  final CartController cartController;
  const _BottomCheckoutBar({required this.cartController});

  Future<void> _handleCheckout() async {
    final auth = Get.find<AuthController>();
    
    if (auth.currentUser == null) {
      final loggedIn = await Get.to(() => LoginScreen());
      if (loggedIn == true) {
        Get.to(() => const OrderReviewScreen());
      }
    } else {
      Get.to(() => const OrderReviewScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng thanh toán', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(
                    '\$${cartController.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CheckoutButton(onPressed: _handleCheckout),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nút bấm Thanh toán với Gradient
class _CheckoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CheckoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.payment_rounded, color: Colors.white),
        label: const Text(
          'Thanh toán',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Item hiển thị trong danh sách giỏ hàng
class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final total = item.finalPrice * item.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.image ?? '',
              height: 90,
              width: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 40),
            ),
          ),
          const SizedBox(width: 16),
          
          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.brandName ?? '',
                        maxLines: 1,
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
                    ),
                  ],
                ),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                
                // Hiển thị biến thể (Size/Color...)
                if (item.selectedVariation != null && item.selectedVariation!.isNotEmpty)
                  _buildVariationTag(),

                const SizedBox(height: 12),
                
                // Số lượng và Giá
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QtySelector(
                      quantity: item.quantity,
                      onIncrease: onIncrease,
                      onDecrease: onDecrease,
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
      child: Text(
        item.selectedVariation!.entries.map((e) => "${e.key}: ${e.value}").join(" | "),
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}

/// Bộ chọn số lượng (Qty Selector)
class _QtySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QtySelector({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _QtyButton(icon: Icons.remove, onTap: onDecrease),
          Container(
            constraints: const BoxConstraints(minWidth: 30),
            alignment: Alignment.center,
            child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          _QtyButton(icon: Icons.add, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: Colors.blue.shade700),
      ),
    );
  }
}