import 'package:flutter/material.dart';

import 'network_image_with_fallback.dart';

class BrandCard extends StatelessWidget {
  final String imageUrl;
  final String brandName;
  final int productCount;
  final VoidCallback? onTap;

  const BrandCard({
    super.key,
    required this.imageUrl,
    required this.brandName,
    required this.productCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.trim().isEmpty
                  ? Container(
                      height: 60,
                      width: 60,
                      color: Colors.blue.shade50,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.store,
                        color: Colors.blue.shade300,
                        size: 28,
                      ),
                    )
                  : NetworkImageWithFallback(
                      imageUrl: imageUrl,
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    brandName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Colors.blue, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$productCount products',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
