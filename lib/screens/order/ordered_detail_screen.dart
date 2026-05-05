import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thuc_hanh/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String phone = "";
  bool isLoadingPhone = true;

  @override
  void initState() {
    super.initState();
    _fetchUserPhone();
  }

  /// ================= FETCH PHONE =================
  Future<void> _fetchUserPhone() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.order.userId)
          .get();
      if (snapshot.exists && mounted) {
        setState(() {
          phone = snapshot.data()?['phone'] ?? "Chưa cập nhật";
          isLoadingPhone = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingPhone = false);
    }
  }

  /// ================= LOGIC TRẠNG THÁI =================
  int _getStepIndex(String status) {
    switch (status.toLowerCase()) {
      case "created":
      case "pending":
        return 0;
      case "processing":
        return 1;
      case "shipped":
        return 2;
      case "delivered":
        return 3;
      default:
        return -1;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case "created":
        return "Mới tạo";
      case "pending":
        return "Chờ xử lý";
      case "processing":
        return "Đang đóng gói";
      case "shipped":
        return "Đang giao hàng";
      case "delivered":
        return "Đã giao thành công";
      case "cancelled":
        return "Đã hủy";
      case "returned":
        return "Đã trả hàng";
      case "refunded":
        return "Đã hoàn tiền";
      default:
        return status;
    }
  }

  bool _isSpecialStatus(String status) {
    final s = status.toLowerCase();
    return s == "cancelled" || s == "returned" || s == "refunded";
  }

  String _getPaymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case "cash":
        return "Thanh toán khi nhận hàng (COD)";
      case "bank":
        return "Chuyển khoản ngân hàng";
      default:
        return method;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Đang xử lý";
    return "${date.day}/${date.month}/${date.year}";
  }

  String _buildAddress(Map<String, dynamic> addr) {
    return "${addr['number'] ?? ''} ${addr['street'] ?? ''}, ${addr['ward'] ?? ''}, ${addr['city'] ?? ''}";
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final currentStep = _getStepIndex(order.orderStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Nền xám rất nhẹ đồng bộ App
      appBar: AppBar(
        title: const Text(
          "Chi tiết đơn hàng",
          style: TextStyle(fontWeight: FontWeight.bold),
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. MÃ ĐƠN HÀNG & TRẠNG THÁI CHUNG
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mã đơn hàng",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "#${order.id.toUpperCase()}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isSpecialStatus(order.orderStatus)
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(order.orderStatus),
                      style: TextStyle(
                        color: _isSpecialStatus(order.orderStatus)
                            ? Colors.red
                            : Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// 2. STEPPER TRẠNG THÁI ĐƠN HÀNG
            const Text(
              "Hành trình đơn hàng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isSpecialStatus(order.orderStatus)
                  ? _buildSpecialStatusUI(order.orderStatus)
                  : _buildHorizontalStepper(currentStep),
            ),
            const SizedBox(height: 20),

            /// 3. DANH SÁCH SẢN PHẨM
            const Text(
              "Sản phẩm",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...order.products.map((item) => _buildProductCard(item)),
            const SizedBox(height: 20),

            /// 4. THÔNG TIN GIAO HÀNG & LIÊN HỆ
            const Text(
              "Thông tin nhận hàng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    "Địa chỉ",
                    _buildAddress(order.shippingAddress),
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.phone_android_outlined,
                    "Số điện thoại",
                    isLoadingPhone ? "Đang tải..." : phone,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    "Ngày giao dự kiến",
                    _formatDate(order.shippingDate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// 5. TỔNG KẾT THANH TOÁN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _priceSummaryRow("Tạm tính", order.subTotal),
                  _priceSummaryRow(
                    "Phí vận chuyển",
                    order.shippingAmount.toDouble(),
                  ),
                  _priceSummaryRow("Thuế", order.taxAmount),
                  if (order.couponDiscountAmount > 0)
                    _priceSummaryRow(
                      "Giảm giá",
                      -order.couponDiscountAmount,
                      isDiscount: true,
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(thickness: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng thanh toán",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "\$${order.totalAmount.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 20,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _getPaymentMethodText(order.paymentMethod),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            /// 6. NÚT HỦY ĐƠN
            if (order.orderStatus.toLowerCase() == "created")
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => _confirmCancel(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Hủy đơn hàng",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ================= UI WIDGETS =================
  Widget _buildHorizontalStepper(int current) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStepCircle(Icons.receipt_long, "Đặt hàng", current >= 0),
        _buildStepLine(current >= 1),
        _buildStepCircle(Icons.inventory_2, "Đóng gói", current >= 1),
        _buildStepLine(current >= 2),
        _buildStepCircle(Icons.local_shipping, "Giao hàng", current >= 2),
        _buildStepLine(current >= 3),
        _buildStepCircle(Icons.check_circle, "Hoàn tất", current >= 3),
      ],
    );
  }

  Widget _buildStepCircle(IconData icon, String label, bool isDone) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDone ? Colors.blue : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDone ? Colors.white : Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDone ? Colors.blue.shade700 : Colors.grey,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? Colors.blue : Colors.grey.shade200,
      ),
    );
  }

  Widget _buildSpecialStatusUI(String status) {
    IconData icon = Icons.info;
    Color color = Colors.grey;

    if (status.toLowerCase() == "cancelled") {
      icon = Icons.cancel;
      color = Colors.red;
    } else if (status.toLowerCase() == "returned") {
      icon = Icons.assignment_return;
      color = Colors.orange;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 12),
        Text(
          _getStatusText(status),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Số lượng: x${item.quantity}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            "\$${item.price}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade300),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceSummaryRow(
    String label,
    double value, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            "${isDiscount ? '-' : ''}\$${value.abs().toStringAsFixed(0)}",
            style: TextStyle(
              color: isDiscount ? Colors.red : Colors.black87,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= LOGIC HỦY ĐƠN =================
  void _confirmCancel(OrderModel order) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Xác nhận hủy đơn"),
        content: const Text(
          "Bạn có chắc chắn muốn hủy đơn hàng này không? Hành động này không thể hoàn tác.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Đóng", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final orderController = Get.find<OrderController>();
              await FirebaseFirestore.instance
                  .collection('orders')
                  .doc(order.docId)
                  .update({
                "orderStatus": "cancelled",
                "updatedAt": DateTime.now(),
              });
              await orderController.revertSoldQuantity(order);
              Get.back();
              Get.back();
              Get.snackbar(
                "Thành công",
                "Đơn hàng của bạn đã được hủy",
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Xác nhận hủy",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}