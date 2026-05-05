import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/widgets/product_card.dart';
import '../../controller/brand_controller.dart';
class BrandDetailScreen extends StatefulWidget {
final String brandId;
final String brandName;
const BrandDetailScreen({
super.key,
required this.brandId,
required this.brandName,
});
@override
State<BrandDetailScreen> createState() => _BrandDetailScreenState();
}
class _BrandDetailScreenState extends State<BrandDetailScreen> {
late AllBrandController controller;
// Cấu hình filter để đồng bộ với các màn hình trước
final Map<String, String> _filterMap = {
'Tên A-Z': 'name',
'Giá thấp → cao': 'low_price',
'Giá cao → thấp': 'high_price',
};
@override
void initState() {
super.initState();
controller = Get.find<AllBrandController>();
WidgetsBinding.instance.addPostFrameCallback((_) {
controller.fetchProductsByBrand(widget.brandId);
});
}
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.grey[50],
body: Obx(() {
if (controller.isLoading.value) {
return const Center(
child: CircularProgressIndicator(
valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
),
);
}
return CustomScrollView(
physics: const BouncingScrollPhysics(),
slivers: [
/// 1. APPBAR GRADIENT NHẤT QUÁN
SliverAppBar(
pinned: true,
expandedHeight: 100,
backgroundColor: Colors.blue.shade700,
elevation: 0,
iconTheme: const IconThemeData(color: Colors.white),
centerTitle: true,
title: Text(
widget.brandName,
style: const TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
fontSize: 18,
),
),
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
/// 2. BRAND PROFILE CARD (LÀM MỚI SINH ĐỘNG)
SliverToBoxAdapter(
child: Obx(() {
final brand = controller.brands.firstWhereOrNull(
(b) => b.id == widget.brandId,
);
if (brand == null) return const SizedBox();
return Container(
margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.06),
blurRadius: 15,
offset: const Offset(0, 8),
),
],
),
child: Row(
children: [
/// Logo với hiệu ứng viền
Container(
padding: const EdgeInsets.all(3),
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(
color: Colors.blue.shade100,
width: 2,
),
),
child: CircleAvatar(
radius: 35,
backgroundColor: Colors.blue[50],
backgroundImage: brand.imageUrl != null
? NetworkImage(brand.imageUrl!)
: null,
child: brand.imageUrl == null
? Icon(
Icons.store,
size: 35,
color: Colors.blue.shade300,
)
: null,
),
),
const SizedBox(width: 20),
/// Thông tin Brand
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Flexible(
child: Text(
brand.name,
style: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: Color(0xFF2D2D2D),
),
overflow: TextOverflow.ellipsis,
),
),
const SizedBox(width: 8),
const Icon(
Icons.verified,
color: Colors.blue,
size: 20,
),
],
),
const SizedBox(height: 8),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 4,
),
decoration: BoxDecoration(
color: Colors.blue.shade50,
borderRadius: BorderRadius.circular(12),
),
child: Text(
  "${controller.brandProducts.length} sản
phẩm",
style: TextStyle(
color: Colors.blue.shade700,
fontSize: 12,
fontWeight: FontWeight.w600,
),
),
),
],
),
),
],
),
);
}),
),
/// 3. FILTER CHIPS (THAY THẾ DROPDOWN)
SliverToBoxAdapter(
child: Container(
padding: const EdgeInsets.symmetric(vertical: 12),
child: SingleChildScrollView(
scrollDirection: Axis.horizontal,
padding: const EdgeInsets.symmetric(horizontal: 16),
physics: const BouncingScrollPhysics(),
child: Row(
children: _filterMap.keys.map((filterName) {
final isSelected =
controller.selectedSort.value ==
_filterMap[filterName];
return Padding(
padding: const EdgeInsets.only(right: 10),
child: ChoiceChip(
label: Text(filterName),
selected: isSelected,
selectedColor: Colors.blue.shade600,
backgroundColor: Colors.white,
labelStyle: TextStyle(
color: isSelected
? Colors.white
: Colors.grey.shade700,
fontWeight: isSelected
? FontWeight.bold
: FontWeight.normal,
fontSize: 13,
),
elevation: isSelected ? 4 : 0,
pressElevation: 2,
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(20),
side: BorderSide(
color: isSelected
? Colors.blue.shade600
: Colors.grey.shade200,
),
),
onSelected: (bool selected) {
if (selected) {
controller.sortBrandProducts(
_filterMap[filterName]!,
);
}
},
),
);
}).toList(),
),
),
),
),
/// 4. GRID PRODUCT NHẤT QUÁN
SliverPadding(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical:
8),
sliver: SliverGrid(
gridDelegate: const
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 16,
mainAxisSpacing: 16,
childAspectRatio:
0.65, // Khớp hoàn toàn với HomeScreen & PopularScreen
),
delegate: SliverChildBuilderDelegate((context, index) {
final product = controller.brandProducts[index];
return ProductCard(product: product);
}, childCount: controller.brandProducts.length),
),
),
/// Khoảng trống cuối trang
const SliverToBoxAdapter(child: SizedBox(height: 40)),
],
);
}),
);
}
}