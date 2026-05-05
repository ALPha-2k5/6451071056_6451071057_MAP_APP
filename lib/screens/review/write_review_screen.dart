import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../controller/login_controller.dart';

class WriteReviewScreen extends StatefulWidget {
  final ProductModel product;
  final String? reviewId;

  const WriteReviewScreen({super.key, required this.product, this.reviewId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double rating = 5;
  final TextEditingController reviewController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final auth = Get.find<AuthController>();
  
  List<String> mediaUrls = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.reviewId != null) {
      loadExistingReview();
    }
  }

  Future<void> loadExistingReview() async {
    setState(() => isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          rating = (data['rating'] ?? 5).toDouble();
          titleController.text = data['title'] ?? "";
          reviewController.text = data['reviewText'] ?? '';
          mediaUrls = List<String>.from(data['mediaUrls'] ?? []);
        });
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải dữ liệu đánh giá");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> submitReview() async {
    final user = auth.currentUser;
    if (user == null) {
      Get.snackbar("Lỗi", "Bạn cần đăng nhập để thực hiện");
      return;
    }

    if (titleController.text.trim().isEmpty || reviewController.text.trim().isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng điền đầy đủ tiêu đề và nội dung",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);
    try {
      final reviewData = {
        'productId': widget.product.id,
        'productName': widget.product.title,
        'productImage': widget.product.thumbnail,
        'userId': user.id,
        'userName': "${user.firstName} ${user.lastName}",
        'rating': rating,
        'title': titleController.text.trim(),
        'reviewText': reviewController.text.trim(),
        'mediaUrls': mediaUrls,
        'updatedAt': Timestamp.now(),
        'isApproved': false,
        'isDeleted': false,
      };

      if (widget.reviewId == null) {
        await FirebaseFirestore.instance.collection('reviews').add({
          ...reviewData,
          'createdAt': Timestamp.now(),
        });
      } else {
        await FirebaseFirestore.instance.collection('reviews').doc(widget.reviewId).update(reviewData);
      }

      await updateProductRating();
      Get.back();
      Get.snackbar("Thành công", "Đánh giá của bạn đã được gửi và đang chờ duyệt",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Lỗi", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProductRating() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('productId', isEqualTo: widget.product.id)
        .where('isApproved', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc['rating'] ?? 0).toDouble();
    }
    final count = snapshot.docs.length;
    final avg = count == 0 ? 0.0 : total / count;

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id)
        .update({'rating': avg, 'ratingCount': count});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.reviewId == null ? "Viết đánh giá" : "Sửa đánh giá"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductSummary(),
                const Divider(height: 40),
                _buildStarPicker(),
                const SizedBox(height: 32),
                _buildInputField("Tiêu đề", titleController, "Điều gì quan trọng nhất?"),
                const SizedBox(height: 20),
                _buildInputField("Nội dung chi tiết", reviewController, "Bạn thích hay không thích điểm gì?", maxLines: 5),
                const SizedBox(height: 24),
                _buildMediaSection(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildProductSummary() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(widget.product.thumbnail, width: 70, height: 70, fit: BoxFit.cover),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            widget.product.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStarPicker() {
    return Column(
      children: [
        const Center(child: Text("Bạn chấm sản phẩm này mấy sao?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () => setState(() => rating = index + 1.0),
              icon: Icon(
                index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 45,
                color: Colors.amber,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thêm hình ảnh (URL)", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAddMediaButton(),
              ...mediaUrls.map((url) => _buildImagePreview(url)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddMediaButton() {
    return GestureDetector(
      onTap: _showAddImageDialog,
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.2), style: BorderStyle.solid),
        ),
        child: const Icon(Icons.add_a_photo_outlined, color: Colors.blue),
      ),
    );
  }

  Widget _buildImagePreview(String url) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(url, width: 90, height: 90, fit: BoxFit.cover),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: GestureDetector(
              onTap: () => setState(() => mediaUrls.remove(url)),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : submitReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          widget.reviewId == null ? "Gửi đánh giá" : "Cập nhật đánh giá",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showAddImageDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Thêm link ảnh"),
        content: TextField(
          controller: urlController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Dán URL hình ảnh vào đây..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                setState(() => mediaUrls.add(urlController.text.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }
}