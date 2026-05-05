import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thuc_hanh/routes/app_routes.dart';
import 'package:thuc_hanh/controller/login_controller.dart';
import 'package:thuc_hanh/controller/wishlist_controller.dart';
import 'package:thuc_hanh/data/models/product_model.dart';
class WishlistScreen extends StatefulWidget {
const WishlistScreen({super.key});
@override
State<WishlistScreen> createState() => _WishlistScreenState();
}
class _WishlistScreenState extends State<WishlistScreen> {
final WishlistController wishlistController =
Get.find<WishlistController>();
@override
void initState() {
super.initState();
// Tải dữ liệu wishlist khi vào màn hình
wishlistController.loadWishlist();
}
@override
Widget build(BuildContext context) {
final AuthController authController = Get.find<AuthController>();
bool loggedIn = authController.currentUser != null;
// Nếu chưa đăng nhập, hiển thị màn hình yêu cầu login
if (!loggedIn) {
return _buildLoginRequired(context);
}
return Scaffold(
backgroundColor: Colors.grey[50], // Nền xám nhạt nhất quán
appBar: AppBar(
title: const Text(
'Danh sách yêu thích',
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
),
body: GetBuilder<WishlistController>(
builder: (controller) {
final items = controller.items;
if (items.isEmpty) {
return _buildEmpty();
}
return GridView.builder(
  padding: const EdgeInsets.all(16),
itemCount: items.length,
physics: const BouncingScrollPhysics(),
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 16,
mainAxisSpacing: 16,
childAspectRatio:
0.65, // Nhất quán với HomeScreen và Popular Screen
),
itemBuilder: (context, index) {
final product = items[index];
return _WishlistProductCard(
product: product,
onRemove: () async {
await controller.removeItem(product.id);
// Hiển thị snackbar hiện đại hơn
Get.rawSnackbar(
message: "Đã xóa khỏi danh sách yêu thích",
backgroundColor: Colors.black87,
snackPosition: SnackPosition.BOTTOM,
margin: const EdgeInsets.all(16),
borderRadius: 12,
duration: const Duration(seconds: 2),
);
},
);
},
);
},
),
);
}
/// Trình bày khi danh sách trống
Widget _buildEmpty() {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
padding: const EdgeInsets.all(40),
decoration: BoxDecoration(
color: Colors.red.withOpacity(0.05),
shape: BoxShape.circle,
),
child: Icon(
Icons.favorite_outline_rounded,
size: 80,
color: Colors.red.withOpacity(0.2),
),
),
const SizedBox(height: 24),
const Text(
'Danh sách đang trống',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
color: Color(0xFF2D2D2D),
),
),
const SizedBox(height: 10),
const Text(
'Hãy thêm những sản phẩm bạn yêu thích vào đây!',
textAlign: TextAlign.center,
style: TextStyle(color: Colors.grey),
),
const SizedBox(height: 32),
SizedBox(
width: 200,
child: ElevatedButton(
onPressed: () => Get.back(),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.blue.shade700,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
padding: const EdgeInsets.symmetric(vertical: 14),
elevation: 0,
),
child: const Text(
'Mua sắm ngay',
style: TextStyle(fontWeight: FontWeight.bold),
),
),
),
],
),
);
}
/// Trình bày khi chưa đăng nhập
Widget _buildLoginRequired(BuildContext context) {
return Scaffold(
body: Container(
width: double.infinity,
padding: const EdgeInsets.all(30),
child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
children: [
Container(
padding: const EdgeInsets.all(30),
decoration: BoxDecoration(
color: Colors.blue.withOpacity(0.05),
shape: BoxShape.circle,
),
child: Icon(
Icons.lock_outline_rounded,
size: 80,
color: Colors.blue.shade700,
),
),
const SizedBox(height: 32),
const Text(
'Yêu cầu đăng nhập',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: Color(0xFF2D2D2D),
),
),
const SizedBox(height: 12),
const Text(
'Vui lòng đăng nhập để xem và quản lý\ndanh sách yêu thích của
bạn.',
textAlign: TextAlign.center,
style: TextStyle(color: Colors.grey, height: 1.5),
),
const SizedBox(height: 48),
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: () => Navigator.pushNamed(context,
AppRoutes.login),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.blue.shade700,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
padding: const EdgeInsets.symmetric(vertical: 16),
),
child: const Text(
'Đăng nhập ngay',
style: TextStyle(fontWeight: FontWeight.bold),
),
),
),
TextButton(
onPressed: () => Get.back(),
child: const Text(
'Quay lại',
style: TextStyle(color: Colors.grey),
),
),
],
),
),
);
}
}
class _WishlistProductCard extends StatelessWidget {
final ProductModel product;
final VoidCallback onRemove;
const _WishlistProductCard({required this.product, required
this.onRemove});
@override
Widget build(BuildContext context) {
final bool hasDiscount =
product.salePrice != null && product.salePrice! > 0;
return Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.04),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: ClipRRect(
borderRadius: BorderRadius.circular(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
/// ẢNH SẢN PHẨM
Expanded(
flex: 5,
child: Stack(
children: [
Positioned.fill(
child: Image.network(
  product.thumbnail,
fit: BoxFit.cover,
errorBuilder: (_, __, ___) => Container(
color: Colors.grey.shade100,
child: const Icon(
Icons.broken_image,
color: Colors.grey,
),
),
),
),
/// NHÃN GIẢM GIÁ
if (hasDiscount)
Positioned(
top: 10,
left: 10,
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 8,
vertical: 4,
),
decoration: BoxDecoration(
color: Colors.orangeAccent,
borderRadius: BorderRadius.circular(6),
),
child: Text(
"-${product.salePrice!.toStringAsFixed(0)}%",
style: const TextStyle(
color: Colors.white,
fontSize: 10,
fontWeight: FontWeight.bold,
),
),
),
),
/// NÚT XÓA (Yêu thích)
Positioned(
top: 8,
right: 8,
child: GestureDetector(
onTap: onRemove,
child: Container(
padding: const EdgeInsets.all(6),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.9),
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
  color: Colors.black.withOpacity(0.1),
blurRadius: 4,
),
],
),
child: const Icon(
Icons.favorite,
color: Colors.red,
size: 18,
),
),
),
),
],
),
),
/// THÔNG TIN SẢN PHẨM
Expanded(
flex: 4,
child: Padding(
padding: const EdgeInsets.all(12),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
product.title,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 13,
color: Color(0xFF2D2D2D),
),
),
const SizedBox(height: 4),
Row(
children: [
Text(
product.brandName ?? 'Generic',
style: TextStyle(
fontSize: 10,
color: Colors.blue.shade700,
fontWeight: FontWeight.w500,
),
),
const SizedBox(width: 4),
Icon(
Icons.verified,
size: 10,
color: Colors.blue.shade700,
),
],
),
],
),
Text(
"\$${product.price.toStringAsFixed(0)}",
style: const TextStyle(
fontWeight: FontWeight.w900,
fontSize: 16,
color: Colors.black,
),
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
}