import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/brand_cart.dart';
import '../../controller/brand_controller.dart';
import '../../data/models/brand_model.dart';
import 'brand_detail_screen.dart';

class AllBrandScreen extends StatelessWidget {
  AllBrandScreen({super.key});
  final AllBrandController controller = Get.put(AllBrandController());
  @override
  Widget build(BuildContext context) {
// Kiểm tra chế độ sáng/tối để điều chỉnh màu nền bổ trợ
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
// Màu nền xám nhạt đồng bộ với các màn hình trước đó
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// 1. APP BAR VỚI GRADIENT ĐỒNG NHẤT
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            stretch: true,
            backgroundColor: Colors.blue.shade700,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Thương hiệu phổ biến',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                  ),
                ),
              ),
            ),
          ),

          /// 2. NỘI DUNG CHÍNH
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            sliver: Obx(() {
// Trạng thái đang tải dữ liệu
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                );
              }
// Trạng thái không có thương hiệu nào
              if (controller.brands.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Không tìm thấy thương hiệu nào",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
// Hiển thị danh sách thương hiệu
              return SliverList(
                delegate: SliverChildListDelegate([
                  /// Thông tin số lượng thương hiệu
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Tìm thấy ${controller.brands.length} thương hiệu",
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// Grid Thương hiệu
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.brands.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          1.1, // Điều chỉnh lại tỉ lệ để BrandCard cân đối hơn
                    ),
                    itemBuilder: (context, index) {
                      final brand = controller.brands[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Get.to(
                                  () => BrandDetailScreen(
                                    brandId: brand.id,
                                    brandName: brand.name,
                                  ),
                                );
                              },
                              child: BrandCard(
                                imageUrl: brand.imageUrl,
                                brandName: brand.name,
                                productCount: brand.productsCount,
// Chú ý: Nếu BrandCard của bạn đã có onTapbên trong,
// hãy đảm bảo không bị xung đột với InkWell ở đây.
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ]),
              );
            }),
          ),
        ],
      ),
    );
  }
}
