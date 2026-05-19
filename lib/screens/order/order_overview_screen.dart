import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/order_controller.dart';
import '../../utils/currency.dart';
import '../../controller/cart_controller.dart';
import '../../data/models/coupon_model.dart';

class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({super.key});
  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
// Khởi tạo controller
  final OrderController controller = Get.put(OrderController());
  final CartController cart = Get.find<CartController>();
  final TextEditingController couponController = TextEditingController();
  @override
  void initState() {
    super.initState();
// Gọi dữ liệu một lần duy nhất khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadFromCart();
      controller.fetchAddresses();
    });
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền xám nhạt đồng bộ toàn app
      appBar: AppBar(
        title: const Text(
          "Kiểm tra đơn hàng",
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
        leading: const BackButton(),
      ),
      body: Obx(
        () => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  /// 1. DANH SÁCH SẢN PHẨM
                  _buildSectionTitle("Sản phẩm trong đơn"),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: controller.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.image ?? "",
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.image_not_supported,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.brandName ?? "Thương hiệu",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                            if (index != controller.items.length - 1)
                              Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                                color: Colors.grey.shade100,
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  /// 2. MÃ KHUYẾN MÃI (COUPONS)
                  _buildSectionTitle("Mã khuyến mãi"),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.confirmation_number_outlined,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: couponController,
                            decoration: const InputDecoration(
                              hintText: "Nhập mã giảm giá",
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (couponController.text.isNotEmpty) {
                              controller.applyCoupon(
                                couponController.text.trim(),
                              );
                            } else {
                              Get.snackbar("Thông báo", "Vui lòng nhập mã");
                            }
                          },
                          child: const Text("Áp dụng"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAppliedCouponCard(),
                  const SizedBox(height: 16),
                  _buildAvailableCouponsList(),
                  const SizedBox(height: 24),

                  /// 3. PHƯƠNG THỨC THANH TOÁN
                  _buildSectionTitle("Phương thức thanh toán"),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildPaymentOption(
                          title: "Tiền mặt khi nhận hàng (COD)",
                          value: "cash",
                          icon: Icons.payments_outlined,
                        ),
                        Divider(height: 1, color: Colors.grey.shade100),
                        _buildPaymentOption(
                          title: "Chuyển khoản ngân hàng",
                          value: "bank",
                          icon: Icons.account_balance_outlined,
                        ),
                        if (controller.paymentMethod.value == "bank")
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  "Quét mã để thanh toán",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Image.network(
                                    "https://api.qrserver.com/v1/create-qrcode/?size=150x150&data=payment",
                                    height: 150,
                                    width: 150,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  /// 4. ĐỊA CHỈ GIAO HÀNG
                  _buildSectionTitle("Địa chỉ giao hàng"),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        controller.selectedAddress.value?.fullAddress ??
                            "Chưa chọn địa chỉ",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text("Số điện thoại:${controller.phone.value}"),
                      ),
                      trailing: TextButton(
                        onPressed: () => _showAddressDialog(controller),
                        child: const Text(
                          "Thay đổi",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 5. TỔNG KẾT VÀ THANH TOÁN (BOTTOM PANEL)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _row("Tạm tính", controller.subTotal.value),
                    const SizedBox(height: 8),
                    _row("Phí vận chuyển", controller.shippingFee.value),
                    const SizedBox(height: 8),
                    _row(
                      "Giảm giá",
                      -controller.discountAmount.value,
                      color: Colors.red,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    _row(
                      "Tổng thanh toán",
                      controller.total,
                      bold: true,
                      fontSize: 18,
                      color: Colors.blue.shade800,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: Obx(() {
                        final isLoading = controller.isCreatingOrder.value;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.blue.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (controller.selectedAddress.value == null) {
                                    Get.snackbar(
                                      "Lỗi",
                                      "Vui lòng chọn địa chỉ giao hàng",
                                      backgroundColor: Colors.red.shade400,
                                      colorText: Colors.white,
                                    );
                                    return;
                                  }
                                  await controller.createOrder();
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "XÁC NHẬN ĐẶT HÀNG",
                                  style: TextStyle(
                                    fontSize: 16,
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
            ),
          ],
        ),
      ),
    );
  }

  /// Widget tiêu đề từng phần
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D2D2D),
      ),
    );
  }

  /// Widget lựa chọn thanh toán
  Widget _buildPaymentOption({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isSelected = controller.paymentMethod.value == value;
    return InkWell(
      onTap: () => controller.paymentMethod.value = value,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: RadioListTile<String>(
          value: value,
          groupValue: controller.paymentMethod.value,
          onChanged: (v) => controller.paymentMethod.value = v!,
          activeColor: Colors.blue,
          secondary: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  /// HỘI THOẠI CHỌN ĐỊA CHỈ
  void _showAddressDialog(OrderController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Địa chỉ nhận hàng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (controller.addresses.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("Bạn chưa có địa chỉ nào được lưu."),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              itemCount: controller.addresses.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final addr = controller.addresses[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on, color: Colors.blue),
                  title: Text(
                    addr.fullAddress,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    controller.selectAddress(addr);
                    Get.back();
                  },
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Đóng")),
        ],
      ),
    );
  }

  /// HIỂN THỊ DÒNG GIÁ TIỀN
  Widget _row(
    String title,
    double value, {
    bool bold = false,
    double fontSize = 14,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            color: bold ? Colors.black : Colors.grey.shade600,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value < 0 ? "- ${formatVnd(value.abs())}" : "${formatVnd(value)}",
          style: TextStyle(
            fontSize: fontSize,
            color: color ?? (bold ? Colors.black : Colors.black),
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildAppliedCouponCard() {
    return Obx(() {
      final coupon = controller.coupon.value;
      if (coupon == null) return const SizedBox.shrink();

      final isPercentage = coupon.discountType == DiscountType.percentage;
      final badgeColor = isPercentage ? Colors.deepOrange : Colors.teal;
      final icon = isPercentage ? Icons.percent : Icons.local_offer;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: badgeColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: badgeColor,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Đã áp dụng mã: ${coupon.code}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: badgeColor.shade800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isPercentage ? "${coupon.discountValue}%" : formatVnd(coupon.discountValue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPercentage
                        ? "Mã giảm ${coupon.discountValue}% (Giảm được: ${formatVnd(controller.discountAmount.value)})"
                        : "Mã giảm trực tiếp ${formatVnd(coupon.discountValue)}",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                controller.coupon.value = null;
                controller.discountAmount.value = 0.0;
                couponController.clear();
              },
              icon: const Icon(Icons.close, color: Colors.grey),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAvailableCouponsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mã giảm giá dành cho bạn",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('coupons')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text(
                "Hiện chưa có mã giảm giá nào.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              );
            }

            final docs = snapshot.data!.docs;
            return SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final coupon = CouponModel.fromJson({...data, 'id': docs[index].id});
                  final isPercentage = coupon.discountType == DiscountType.percentage;
                  final primaryColor = isPercentage ? Colors.deepOrange : Colors.teal;

                  return Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isPercentage ? Icons.percent : Icons.local_offer,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isPercentage ? "${coupon.discountValue}%" : "VNĐ",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  coupon.code,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: primaryColor.shade800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  coupon.description.isNotEmpty
                                      ? coupon.description
                                      : (isPercentage ? "Giảm theo phần trăm" : "Giảm trực tiếp tiền mặt"),
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Obx(() {
                                  final isApplied = controller.coupon.value?.code == coupon.code;
                                  return SizedBox(
                                    height: 26,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isApplied ? Colors.grey : primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                      onPressed: isApplied
                                          ? null
                                          : () {
                                              couponController.text = coupon.code;
                                              controller.applyCoupon(coupon.code);
                                            },
                                      child: Text(
                                        isApplied ? "Đang dùng" : "Dùng ngay",
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
