import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewRatingScreen extends StatelessWidget {
  final String productId;
  final double rating;
  final int reviewCount;

  const ReviewRatingScreen({
    super.key,
    required this.productId,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. TỔNG QUAN RATING
            _buildOverviewCard(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                "Nhận xét từ khách hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
              ),
            ),

            /// 2. DANH SÁCH REVIEW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildReviewList(),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Đánh giá sản phẩm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          // Điểm trung bình
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w800, color: Color(0xFF2D3436), letterSpacing: -2),
                ),
                _buildStarRating(rating),
                const SizedBox(height: 8),
                Text(
                  '$reviewCount đánh giá',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(height: 80, width: 1, color: Colors.grey.shade100, margin: const EdgeInsets.symmetric(horizontal: 15)),
          
          // Tiến trình sao
          Expanded(flex: 3, child: _buildStarProgressBars()),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 18,
          color: Colors.amber,
        );
      }),
    );
  }

  Widget _buildStarProgressBars() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .where('isDeleted', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final docs = snapshot.data!.docs;
        final total = docs.length;
        Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
        
        for (var doc in docs) {
          int r = (doc['rating'] ?? 0).toInt();
          if (r >= 1 && r <= 5) counts[r] = (counts[r] ?? 0) + 1;
        }

        return Column(
          children: [5, 4, 3, 2, 1].map((star) {
            return _StarProgressRow(
              star: star,
              value: total == 0 ? 0 : (counts[star]! / total),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildReviewList() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Đã có lỗi xảy ra"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _buildEmptyState();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final isApproved = data['isApproved'] ?? false;
            final isOwner = data['userId'] == currentUserId;

            if (!isApproved && !isOwner) return const SizedBox.shrink();

            return _ReviewItem(
              reviewId: docs[index].id,
              isOwner: isOwner,
              isApproved: isApproved,
              userName: data['userName'] ?? 'Người dùng',
              title: data['title'] ?? '',
              rating: (data['rating'] ?? 0).toDouble(),
              reviewText: data['reviewText'] ?? '',
              mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
              createdAt: (data['createdAt'] as Timestamp).toDate(),
              userImage: data['userProfileImage'],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            "Chưa có đánh giá nào.\nHãy là người đầu tiên nhận xét!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _StarProgressRow extends StatelessWidget {
  final int star;
  final double value;
  const _StarProgressRow({required this.star, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$star', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String reviewId, userName, title, reviewText;
  final String? userImage;
  final double rating;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final bool isOwner, isApproved;

  const _ReviewItem({
    required this.reviewId, required this.isOwner, required this.isApproved,
    required this.title, required this.userName, required this.rating,
    required this.reviewText, required this.createdAt, required this.mediaUrls,
    this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue.shade50,
                backgroundImage: userImage != null ? NetworkImage(userImage!) : null,
                child: userImage == null ? Icon(Icons.person, color: Colors.blue.shade200) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(timeago.format(createdAt, locale: 'vi'), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                  ],
                ),
              ),
              if (isOwner)
                IconButton(
                  onPressed: () => _confirmDelete(context),
                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildStarRow(rating),
          const SizedBox(height: 10),
          if (title.isNotEmpty)
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436))),
          const SizedBox(height: 4),
          Text(reviewText, style: TextStyle(height: 1.5, color: Colors.grey.shade700, fontSize: 14)),
          if (mediaUrls.isNotEmpty) _buildMediaGrid(),
          const SizedBox(height: 16),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildStarRow(double rating) {
    return Row(
      children: List.generate(5, (index) => Icon(
        index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
        size: 16, color: Colors.amber,
      )),
    );
  }

  Widget _buildMediaGrid() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: mediaUrls.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(mediaUrls[index], width: 80, height: 80, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (isOwner && !isApproved)
          _StatusTag(text: "Đang chờ duyệt", color: Colors.orange)
        else
          const SizedBox(),
        _IconLabelButton(icon: Icons.thumb_up_alt_outlined, label: "Hữu ích"),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Xóa đánh giá?"),
        content: const Text("Bạn có chắc chắn muốn xóa phản hồi này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('reviews').doc(reviewId).update({'isDeleted': true});
              Navigator.pop(context);
            },
            child: const Text("Xác nhận xóa"),
          ),
        ],
      ),
    );
  }
}

// Widget phụ trợ cho trạng thái
class _StatusTag extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// Widget phụ trợ cho nút bấm
class _IconLabelButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _IconLabelButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}