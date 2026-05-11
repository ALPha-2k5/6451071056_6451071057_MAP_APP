import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/network_image_with_fallback.dart';
import '../../controller/cart_controller.dart';
import '../../controller/login_controller.dart';
import '../../controller/order_controller.dart';
import '../../controller/product_controller.dart';
import '../../data/models/cart_item_model.dart';
import '../../utils/currency.dart';
import '../review/review_rating_screen.dart';
import '../review/write_review_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductController controller = Get.find<ProductController>();
  final CartController cartController = Get.find<CartController>();
  final OrderController orderController = Get.put(OrderController());

  int quantity = 1;
  String? selectedImage;
  final Map<String, int> selectedAttributes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchProductDetail(widget.productId);
      final product = controller.selectedProduct.value;
      if (product != null && mounted) {
        setState(() {
          selectedImage = product.thumbnail;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value || controller.selectedProduct.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = controller.selectedProduct.value!;
        final bool isOutOfStock = product.isOutOfStock == true ||
            product.stock <= 0 ||
            product.soldQuantity >= product.stock;
        final authController = Get.find<AuthController>();

        return Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 400,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.white,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: BackButton(color: Colors.blue.shade800),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        Positioned.fill(
                          child: NetworkImageWithFallback(
                            imageUrl: selectedImage ?? product.thumbnail,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (isOutOfStock)
                          Container(
                            color: Colors.black.withOpacity(0.4),
                            child: const Center(
                              child: Text(
                                'TẠM HẾT HÀNG',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildThumbnails(product),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.store,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  product.brandName ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: Colors.blue, size: 16),
                              ],
                            ),
                            _buildRatingBadge(product),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatVnd(product.price),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStockStatus(isOutOfStock),
                        const Divider(height: 40),
                        if (authController.currentUser != null)
                          _buildReviewActionSection(product),
                        const SizedBox(height: 10),
                        ...product.attributes.map(
                          (attribute) => _buildAttributeSection(attribute),
                        ),
                        const Text(
                          'Mô tả sản phẩm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.description ?? 'Không có mô tả cho sản phẩm này.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.5,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!isOutOfStock) _buildBottomAction(product),
          ],
        );
      }),
    );
  }

  Widget _buildThumbnails(dynamic product) {
    final imageUrls = <String>{product.thumbnail, ...product.images}.toList();
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: imageUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
          final isSelected = selectedImage == imageUrl;
          return GestureDetector(
            onTap: () => setState(() => selectedImage = imageUrl),
            child: Container(
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade200,
                  width: 2,
                ),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: NetworkImageWithFallback(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingBadge(dynamic product) {
    return GestureDetector(
      onTap: () => Get.to(
        () => ReviewRatingScreen(
          productId: product.id,
          rating: product.rating,
          reviewCount: product.ratingCount,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              '${product.rating}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              ' (${product.ratingCount})',
              style: TextStyle(color: Colors.orange.shade300, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus(bool isOutOfStock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOutOfStock ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOutOfStock ? 'Tạm hết hàng' : 'Đang còn hàng',
        style: TextStyle(
          color: isOutOfStock ? Colors.red : Colors.green,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAttributeSection(dynamic attribute) {
    final name = attribute.name as String;
    final values = attribute.values as List<dynamic>;
    selectedAttributes.putIfAbsent(name, () => 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(values.length, (index) {
            final isSelected = selectedAttributes[name] == index;
            return GestureDetector(
              onTap: () => setState(() => selectedAttributes[name] = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade700 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  values[index].toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReviewActionSection(dynamic product) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getReviewState(product.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final data = snapshot.data!;
        final state = data['state'];
        if (state == 'not_allowed') return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: OutlinedButton.icon(
            onPressed: () {
              Get.to(
                () => WriteReviewScreen(
                  product: product,
                  reviewId: data['reviewId'],
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.blue.shade700),
            ),
            icon: Icon(
              state == 'can_edit' ? Icons.edit : Icons.rate_review,
              size: 18,
            ),
            label: Text(
              state == 'can_edit' ? 'Chỉnh sửa đánh giá' : 'Viết đánh giá sản phẩm',
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomAction(dynamic product) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() => quantity--);
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    quantity.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => quantity++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() {
                final selectedVariation = <String, String>{};
                for (final attr in product.attributes) {
                  final index = selectedAttributes[attr.name] ?? 0;
                  selectedVariation[attr.name] = attr.values[index].toString();
                }

                final isAdded = cartController.isInCart(product.id, selectedVariation);
                return ElevatedButton(
                  onPressed: isAdded
                      ? null
                      : () {
                          cartController.addToCart(
                            CartItemModel(
                              productId: product.id,
                              quantity: quantity,
                              image: selectedImage,
                              price: product.price,
                              title: product.title,
                              brandName: product.brandName,
                              selectedVariation: selectedVariation,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: Colors.blue.withOpacity(0.4),
                  ),
                  child: Text(
                    isAdded ? 'ĐÃ Ở TRONG GIỎ' : 'THÊM VÀO GIỎ HÀNG',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginDialog() {
    Get.defaultDialog(
      title: 'Yêu cầu đăng nhập',
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      middleText: 'Vui lòng đăng nhập để lưu sản phẩm yêu thích.',
      textConfirm: 'Đăng nhập',
      textCancel: 'Để sau',
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      onConfirm: () {
        Get.back();
        Get.toNamed('/login');
      },
    );
  }

  Future<Map<String, dynamic>> getReviewState(String productId) async {
    final orderController = Get.find<OrderController>();
    final user = Get.find<AuthController>().currentUser;
    if (user == null) {
      return {'state': 'not_allowed'};
    }

    final purchased = await orderController.orderService.hasUserPurchasedProduct(
      userId: user.id,
      productId: productId,
    );
    if (!purchased) return {'state': 'not_allowed'};

    final reviewed = await orderController.hasUserReviewedProduct(
      userId: user.id,
      productId: productId,
    );
    if (reviewed) {
      final snapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: user.id)
          .where('isDeleted', isEqualTo: false)
          .limit(1)
          .get();
      return {'state': 'can_edit', 'reviewId': snapshot.docs.first.id};
    }

    return {'state': 'can_write'};
  }
}