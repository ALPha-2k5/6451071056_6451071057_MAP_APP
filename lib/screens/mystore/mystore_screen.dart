import 'package:thuc_hanh/controller/mystore_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/product_card.dart';
import 'all_brand_screen.dart';
import 'brand_detail_screen.dart';
import '/controller/brand_controller.dart';
import '/screens/product/product_by_subcategory_screen.dart';

class MystoreScreen extends StatelessWidget {
  MystoreScreen({super.key});
  final MyStoreController controller = Get.put(MyStoreController());
  final AllBrandController brandController = Get.put(AllBrandController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Đồng bộ màu nền xám nhẹ
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingSkeleton();
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            /// 1. APP BAR GRADIENT (NHẤT QUÁN VỚI HOME)
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              floating: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade700, Colors.blue.shade400],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          const Text(
                            "Cửa hàng",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                          ),
                          const Spacer(),
                          _buildHeaderIcon(Icons.search_rounded, () {}),
                          const SizedBox(width: 10),
                          _buildHeaderIcon(
                            Icons.notifications_none_rounded,
                            () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// 2. FEATURED BRANDS
            _buildSectionTitle(
              context,
              "Các thương hiệu nổi bật",
              onSeeAll: () {
                Get.to(() => AllBrandScreen());
              },
            ),
            _buildFeaturedBrands(),

            /// 3. CATEGORY TABS (STICKY)
            _buildCategoryTabs(),

            /// 4. BRAND BANNERS
            _buildSectionTitle(context, "Thương hiệu trong danh mục"),
            _buildBrandBanner(),

            /// 5. PRODUCTS
            _buildSectionTitle(
              context,
              "Bạn có thể quan tâm",
              onSeeAll: () {
                final selectedIndex = controller.selectedCategoryIndex.value;
                final selectedCategory = controller.categories[selectedIndex];
                Get.to(
                  () => ProductBySubCategoryScreen(
                    categoryId: selectedCategory.id,
                    categoryName: selectedCategory.name,
                  ),
                );
              },
            ),
            _buildProductGrid(),
// Padding phía dưới cùng
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.blue.shade400],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _SkeletonBox(width: 120, height: 22, radius: 8),
                  Spacer(),
                  _SkeletonCircle(size: 32),
                  SizedBox(width: 10),
                  _SkeletonCircle(size: 32),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: _SkeletonBox(width: 180, height: 18, radius: 8),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, __) => const _BrandSkeletonCard(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => const _SkeletonBox(width: 96, height: 32, radius: 16),
          ),
        ),
        const SizedBox(height: 18),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: _SkeletonBox(width: 150, height: 18, radius: 8),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (_, __) => const _ProductSkeletonCard(),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  /// Nút bấm trên Header mờ mờ đồng bộ
  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 25, 24, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: const Text(
                  "Xem tất cả",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// FEATURED BRANDS
  Widget _buildFeaturedBrands() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.featuredBrands.length,
          itemBuilder: (_, index) {
            final brand = controller.featuredBrands[index];
            return GestureDetector(
              onTap: () {
                Get.to(
                  () => BrandDetailScreen(
                    brandId: brand.id,
                    brandName: brand.name,
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade50,
                      child: ClipOval(
                        child: brand.imageUrl.trim().isEmpty
                            ? Icon(
                                Icons.store,
                                color: Colors.blue.shade300,
                                size: 24,
                              )
                            : Image.network(
                                brand.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.store,
                                  color: Colors.blue.shade300,
                                  size: 24,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      brand.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// CATEGORY TAB (Sử dụng Blue Theme nhã nhặn hơn)
  Widget _buildCategoryTabs() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 65,
        maxHeight: 65,
        child: Container(
          color: Colors.grey[50],
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.categories.length,
              itemBuilder: (_, index) {
                final isSelected =
                    controller.selectedCategoryIndex.value == index;
                return GestureDetector(
                  onTap: () => controller.selectCategory(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade600 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        controller.categories[index].name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Colors.blueGrey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// BRAND BANNER (Modern Dark Card)
  Widget _buildBrandBanner() {
    return SliverToBoxAdapter(
      child: Column(
        children: controller.categoryBrands.map((brand) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF232526), const Color(0xFF414345)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Cửa hàng chính hãng",
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        "Theo dõi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// PRODUCT GRID (Đồng bộ tỉ lệ 0.65)
  Widget _buildProductGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.65, // Tỉ lệ giống trang chủ và trang Popular
        ),
        delegate: SliverChildBuilderDelegate(
          (_, index) => ProductCard(product: controller.products[index]),
          childCount: controller.products.length,
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({required this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;

  const _SkeletonCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BrandSkeletonCard extends StatelessWidget {
  const _BrandSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SkeletonCircle(size: 50),
          SizedBox(height: 8),
          _SkeletonBox(width: 56, height: 10, radius: 8),
        ],
      ),
    );
  }
}

class _ProductSkeletonCard extends StatelessWidget {
  const _ProductSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBox(width: double.infinity, height: 110, radius: 16),
            SizedBox(height: 12),
            _SkeletonBox(width: 110, height: 12, radius: 8),
            SizedBox(height: 8),
            _SkeletonBox(width: 70, height: 12, radius: 8),
          ],
        ),
      ),
    );
  }
}

/// Helper class for Sticky Headers
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
