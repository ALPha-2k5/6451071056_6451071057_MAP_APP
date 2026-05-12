import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thuc_hanh/controller/cart_controller.dart';
import 'package:thuc_hanh/controller/login_controller.dart';
import 'package:thuc_hanh/data/models/address_model.dart';
import 'package:thuc_hanh/data/models/cart_item_model.dart';
import 'package:thuc_hanh/data/models/coupon_model.dart';
import 'package:thuc_hanh/data/models/order_model.dart';
import 'package:thuc_hanh/data/services/order_service.dart';
import 'package:thuc_hanh/controller/product_controller.dart';
import 'package:thuc_hanh/screens/order/order_success_screen.dart';
import 'package:get/get.dart';
class OrderController extends GetxController {
/// ================= CONTROLLER =================
final cart = Get.find<CartController>();
final auth = Get.find<AuthController>();
/// ================= STATE =================
RxList<CartItemModel> items = <CartItemModel>[].obs;
RxDouble subTotal = 0.0.obs;
RxDouble tax = 0.0.obs;
RxDouble shippingFee = 0.0.obs;
RxDouble discountAmount = 0.0.obs;
Rxn<CouponModel> coupon = Rxn<CouponModel>();
Rxn<AddressModel> selectedAddress = Rxn<AddressModel>();
RxList<AddressModel> addresses = <AddressModel>[].obs;
RxString phone = "".obs;
RxString paymentMethod = "cash".obs; // cash | bank
/// ================= INIT =================
void loadFromCart() {
items.assignAll(cart.cartItems);
subTotal.value = items.fold(0, (sum, e) => sum + (e.price * e.quantity));
_calculateTax();
}
void _calculateTax() {
tax.value = subTotal.value * 0.1;
}
/// ================= SHIPPING =================
Future<void> calculateShipping(double distanceKm) async {
shippingFee.value = distanceKm * 5000; // 5k/km
}
/// ================= COUPON =================
Future<void> applyCoupon(String code) async {
try {
final snapshot = await FirebaseFirestore.instance
.collection('coupons')
.where('code', isEqualTo: code.trim())
.get();
if (snapshot.docs.isEmpty) {
Get.snackbar("Error", "Coupon không tồn tại");
return;
}
final doc = snapshot.docs.first;
final data = doc.data();
final c = CouponModel.fromJson({
...data,
'id': doc.id, // 🔥 FIX
});
final now = DateTime.now();
/// ===== VALIDATE =====
if (!c.isActive) {
Get.snackbar("Error", "Coupon chưa active");
return;
}
if (c.startDate != null && now.isBefore(c.startDate!)) {
Get.snackbar("Error", "Chưa tới ngày sử dụng");
return;
}
if (c.endDate != null && now.isAfter(c.endDate!)) {
Get.snackbar("Error", "Coupon đã hết hạn");
return;
}
if (c.usageLimit != -1 && c.usageCount >= c.usageLimit) {
Get.snackbar("Error", "Coupon đã hết lượt");
return;
}
/// ===== CALCULATE DISCOUNT =====
double discount = 0;
if (c.discountType == DiscountType.percentage) {
discount = subTotal.value * c.discountValue / 100;
} else {
discount = c.discountValue;
}
/// 🔥 QUAN TRỌNG: set coupon
coupon.value = c;
discountAmount.value = discount;
Get.snackbar("Success", "Áp dụng coupon thành công");
} catch (e) {
  Get.snackbar("Error", "Lỗi coupon: $e");
}
}
/// ================= TOTAL =================
double get total {
return subTotal.value +
tax.value +
shippingFee.value -
discountAmount.value;
}
/// ================= ADDRESS =================
Future<void> fetchAddresses() async {
phone.value = auth.currentUser?.phone ?? "";
final snapshot = await FirebaseFirestore.instance
.collection('users')
.doc(auth.currentUser!.id)
.collection('addresses')
.get();
    addresses.value = snapshot.docs
        .map((e) => AddressModel.fromMap(e.id, e.data()))
        .toList();

    // Auto select default address or first address
    if (addresses.isNotEmpty && selectedAddress.value == null) {
      final defaultAddr = addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      );
      selectAddress(defaultAddr);
    }
  }

void selectAddress(AddressModel address) {
selectedAddress.value = address;
shippingFee.value = 15000;
}
/// ================= CREATE ORDER =================
Future<bool> createOrder() async {
  final int shipping = shippingFee.value.toInt();
  if (selectedAddress.value == null) {
    Get.snackbar("Error", "Vui lòng chọn địa chỉ");
    return false;
  }
  try {
    isCreatingOrder.value = true;
    final totalAmount = total;
    final order = OrderModel(
      docId: '',
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: auth.currentUser!.id,
      userDeviceToken: '',
      products: items,
      subTotal: subTotal.value,
      shippingAmount: shipping,
      taxRate: 0.1,
      taxAmount: tax.value,
      coupon: coupon.value,
      couponDiscountAmount: discountAmount.value,
      pointsUsed: 0,
      pointsDiscountAmount: 0,
      totalDiscountAmount: discountAmount.value,
      totalAmount: totalAmount,
      paymentStatus: "pending",
      orderStatus: "created",
      orderDate: DateTime.now(),
      shippingAddress: selectedAddress.value!.toMap(),
      activities: [],
      itemCount: items.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      paymentMethod: paymentMethod.value,
      paymentMethodType: paymentMethod.value == "bank"
          ? PaymentMethods.bank
          : PaymentMethods.cash,
    );

    // 1. Tìm coupon doc reference trước (ngoại trừ transaction để an toàn)
    DocumentReference? couponDocRef;
    if (coupon.value != null) {
      final couponQuery = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: coupon.value!.code)
          .limit(1)
          .get();
      if (couponQuery.docs.isNotEmpty) {
        couponDocRef = couponQuery.docs.first.reference;
      }
    }

    // 2. Tạo document reference cho đơn hàng mới
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    order.docId = orderRef.id;

    // 3. Thực hiện mọi thay đổi DB trong MỘT Transaction duy nhất
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // --- PHẦN ĐỌC (READS) ---
      // Lưu ý: Tất cả các lệnh get() phải thực hiện TRƯỚC các lệnh set/update/delete
      
      // A. Đọc dữ liệu các sản phẩm
      final List<DocumentSnapshot> productSnapshots = [];
      for (var item in items) {
        final productRef = FirebaseFirestore.instance.collection('products').doc(item.productId);
        productSnapshots.add(await transaction.get(productRef));
      }

      // B. Đọc dữ liệu coupon
      DocumentSnapshot? couponSnapshot;
      if (couponDocRef != null) {
        couponSnapshot = await transaction.get(couponDocRef);
      }

      // --- PHẦN GHI (WRITES) ---
      // Sau khi đã đọc xong toàn bộ snapshot cần thiết, bắt đầu thực hiện các thay đổi

      // 1. Tạo đơn hàng
      transaction.set(orderRef, order.toJson());

      // 2. Cập nhật số lượng đã bán
      for (int i = 0; i < items.length; i++) {
        final snapshot = productSnapshots[i];
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final int currentSold = data['soldQuantity'] ?? 0;
          final int stock = data['stock'] ?? 0;
          final int newSold = currentSold + items[i].quantity;
          final bool isOutOfStock = newSold >= stock;

          transaction.update(snapshot.reference, {
            'soldQuantity': newSold,
            'isOutOfStock': isOutOfStock,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // 3. Tăng usage coupon
      if (couponSnapshot != null && couponSnapshot.exists) {
        transaction.update(couponSnapshot.reference, {
          'usageCount': FieldValue.increment(1),
        });
      }
    });


    // 3. Refresh UI sản phẩm
    try {
      final productController = Get.find<ProductController>();
      await productController.refreshProductData();
    } catch (e) {
      print("ProductController not found, skipping refresh");
    }

    // 4. Xóa giỏ hàng
    cart.cartItems.clear();

    Get.offAll(() => const OrderSuccessScreen());
    return true;

  } catch (e) {
    Get.snackbar("Error", "Tạo đơn thất bại: $e");
    return false;
  } finally {
    isCreatingOrder.value = false;
  }
}
/// ================= COUPON USAGE =================
Future<void> increaseCouponUsage() async {
if (coupon.value == null) return;
final snapshot = await FirebaseFirestore.instance
.collection('coupons')
.where('code', isEqualTo: coupon.value!.code)
.get();
if (snapshot.docs.isEmpty) return;
final docId = snapshot.docs.first.id;
await
FirebaseFirestore.instance.collection('coupons').doc(docId).update({
'usageCount': FieldValue.increment(1),
});
}
/// ================= DISTANCE =================
double calculateDistanceKm(
double lat1,
double lon1,
double lat2,
double lon2,
) {
const R = 6371;
final dLat = _deg2rad(lat2 - lat1);
final dLon = _deg2rad(lon2 - lon1);
final a =
sin(dLat / 2) * sin(dLat / 2) +
cos(_deg2rad(lat1)) *
cos(_deg2rad(lat2)) *
sin(dLon / 2) *
sin(dLon / 2);
final c = 2 * atan2(sqrt(a), sqrt(1 - a));
return R * c;
}
double _deg2rad(double deg) => deg * (pi / 180);
///////==================
RxList<OrderModel> myOrders = <OrderModel>[].obs;
RxBool isLoadingOrders = false.obs;
RxBool isCreatingOrder = false.obs;
final orderService = OrderService();
Future<void> fetchMyOrders() async {
try {
isLoadingOrders.value = true;
final userId = auth.currentUser!.id;
final orders = await orderService.getOrdersByUser(userId);
myOrders.assignAll(orders);
} catch (e) {
Get.snackbar("Error", "Không load được orders: $e");
} finally {
isLoadingOrders.value = false;
}
}
Future<bool> cancelOrder(OrderModel order) async {
  if (isLoadingOrders.value) return false;
  try {
    isLoadingOrders.value = true;

    final orderRef = FirebaseFirestore.instance.collection("orders").doc(order.docId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // 1. READ Order
      final orderSnapshot = await transaction.get(orderRef);
      if (!orderSnapshot.exists) {
        throw "Đơn hàng không tồn tại";
      }

      final data = orderSnapshot.data()!;
      final String currentStatus = data['orderStatus'] ?? '';
      final bool isReverted = data['isQuantityReverted'] ?? false;

      if (currentStatus == 'cancelled') return;

      // 2. READ all Products (must be before any writes)
      Map<String, DocumentSnapshot> productSnapshots = {};
      if (!isReverted) {
        for (var item in order.products) {
          final productRef = FirebaseFirestore.instance.collection('products').doc(item.productId);
          productSnapshots[item.productId] = await transaction.get(productRef);
        }
      }

      // 3. WRITE updates
      // Update order status
      transaction.update(orderRef, {
        "orderStatus": "cancelled",
        "isQuantityReverted": true,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      // Update product quantities
      if (!isReverted) {
        for (var item in order.products) {
          final snapshot = productSnapshots[item.productId];
          if (snapshot != null && snapshot.exists) {
            final productData = snapshot.data() as Map<String, dynamic>;
            final int currentSold = productData['soldQuantity'] ?? 0;
            final int stock = productData['stock'] ?? 0;
            final int quantityToRevert = item.quantity;

            final int newSold = (currentSold - quantityToRevert).clamp(0, 999999);
            final bool isOutOfStock = newSold >= stock;

            transaction.update(snapshot.reference, {
              'soldQuantity': newSold,
              'isOutOfStock': isOutOfStock,
            });
          }
        }
      }
    });

    // 4. Thông báo thành công trước
    Get.snackbar("Thành công", "Đơn hàng đã được hủy");

    // Đợi 1 chút để snackbar hiển thị rồi mới refresh data
    await Future.delayed(const Duration(milliseconds: 500));

    // 5. Refresh danh sách đơn hàng của tôi
    await fetchMyOrders();

    // 6. Refresh UI sản phẩm
    try {
      final productController = Get.find<ProductController>();
      await productController.refreshProductData();
    } catch (e) {
      print("ProductController not found, skipping refresh");
    }

    return true;

  } catch (e) {
    Get.snackbar("Lỗi", "Hủy đơn thất bại: $e");
    return false;
  } finally {
    isLoadingOrders.value = false;
  }
}
Future<bool> canReviewProduct(String productId) async {
final userId = auth.currentUser!.id;
// 1. đã mua + delivered
final purchased = await orderService.hasUserPurchasedProduct(
userId: userId,
productId: productId,
);
if (!purchased) return false;
// 2. đã review chưa
final alreadyReviewed = await hasUserReviewedProduct(
userId: userId,
productId: productId,
);
return !alreadyReviewed;
}
Future<bool> hasUserReviewedProduct({
required String userId,
required String productId,
}) async {
  final snapshot = await FirebaseFirestore.instance
.collection('reviews')
.where('userId', isEqualTo: userId)
.where('productId', isEqualTo: productId)
.where('isDeleted', isEqualTo: false)
.get();
return snapshot.docs.isNotEmpty;
}
// updateSoldQuantityAfterOrder is now integrated into createOrder transaction for efficiency

// Removed revertSoldQuantity as it is now part of the cancelOrder transaction
}
