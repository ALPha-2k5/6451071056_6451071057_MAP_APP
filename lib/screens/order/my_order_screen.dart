import 'package:thuc_hanh/screens/order/ordered_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/order_controller.dart';
import '../../utils/currency.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});
  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  final controller = Get.put(OrderController());
  final TextEditingController searchController = TextEditingController();
  final RxString selectedFilter = "all".obs;
  @override
  void initState() {
    super.initState();
    controller.fetchMyOrders();
  }

// Logic lọc đơn hàng
  List get filteredOrders {
    var orders = controller.myOrders;

    /// LỌC THEO TRẠNG THÁI
    if (selectedFilter.value != "all") {
      orders = orders
          .where(
            (o) =>
                o.orderStatus.toLowerCase() ==
                selectedFilter.value.toLowerCase(),
          )
          .toList()
          .obs;
    }

    /// TÌM KIẾM THEO MÃ ĐƠN HÀNG
    if (searchController.text.isNotEmpty) {
      orders = orders
          .where(
            (o) => o.id.toString().toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ),
          )
          .toList()
          .obs;
    }
    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Đồng bộ màu nền ứng dụng
      body: Column(
        children: [
          /// 1. CUSTOM HEADER VỚI GRADIENT (NHẤT QUÁN VỚI HOME)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade700, Colors.blue.shade400],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  AppBar(
                    title: const Text(
                      'Đơn hàng của tôi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          /// 2. HỆ THỐNG FILTER CHIPS
          _buildFilterBar(),

          /// 3. DANH SÁCH ĐƠN HÀNG
          Expanded(
            child: Obx(() {
              if (controller.isLoadingOrders.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return filteredOrders.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _OrderHistoryCard(
                          orderCode: "#${order.id.toString().toUpperCase()}",
                          status: order.orderStatus,
                          orderDate: _formatDate(order.orderDate),
                          deliveryDate: order.shippingDate != null
                              ? _formatDate(order.shippingDate!)
                              : "Đang xử lý",
                          total: order.totalAmount,
                          onTap: () {
                            Get.to(() => OrderDetailScreen(order: order));
                          },
                        );
                      },
                    );
            }),
          ),
        ],
      ),
    );
  }

  /// THANH TÌM KIẾM MODERN
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: "Tìm mã đơn hàng (ví dụ: 123...)",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Colors.blue),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  /// THANH LỌC TRẠNG THÁI (SCROLLABLE CHIPS)
  Widget _buildFilterBar() {
    final filters = {
      "all": "Tất cả",
      "created": "Chờ xem xét",
      "processing": "Đang xử lý",
      "shipped": "Vận chuyển",
      "delivered": "Đã giao",
      "cancelled": "Đã hủy",
      "returned": "Hoàn trả",
    };
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: filters.entries.map((entry) {
          return Obx(() {
            final isSelected = selectedFilter.value == entry.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (val) => selectedFilter.value = entry.key,
                selectedColor: Colors.blue.shade600,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.blue.shade100),
                ),
                elevation: isSelected ? 3 : 0,
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "Không tìm thấy đơn hàng nào",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}

/// ================= HIỂN THỊ CARD ĐƠN HÀNG =================
class _OrderHistoryCard extends StatelessWidget {
  final String orderCode;
  final String status;
  final String orderDate;
  final String deliveryDate;
  final double total;
  final VoidCallback onTap;
  const _OrderHistoryCard({
    required this.orderCode,
    required this.status,
    required this.orderDate,
    required this.deliveryDate,
    required this.total,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    switch (status.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusText = "Đã giao";
        break;
      case 'processing':
        statusColor = Colors.blue;
        statusIcon = Icons.hourglass_empty;
        statusText = "Đang xử lý";
        break;
      case 'shipped':
        statusColor = Colors.orange;
        statusIcon = Icons.local_shipping_outlined;
        statusText = "Đang giao";
        break;
      case 'created':
        statusColor = Colors.amber.shade700;
        statusIcon = Icons.pending_actions;
        statusText = "Chờ duyệt";
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        statusText = "Đã hủy";
        break;
      case 'returned':
        statusColor = Colors.purple;
        statusIcon = Icons.assignment_return_outlined;
        statusText = "Hoàn trả";
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = status;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            /// Phần Header của Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    orderCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Phần Body của Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoTile(
                        "Ngày đặt",
                        orderDate,
                        Icons.calendar_month,
                      ),
                      _buildInfoTile(
                        "Ngày giao",
                        deliveryDate,
                        Icons.local_shipping,
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng cộng",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatVnd(total),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: statusColor == Colors.red
                              ? Colors.red
                              : Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
