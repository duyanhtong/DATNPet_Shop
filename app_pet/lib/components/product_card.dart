import 'package:flutter/material.dart';

import 'package:shop_app/models/product.model.dart'; // Import ProductModel 클래스
import '../constants.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    this.width = 140,
    this.aspectRatio = 1.02,
    required this.product,
    required this.onPress,
    this.isAdmin = false,
  }) : super(key: key);

  final double width, aspectRatio;
  final ProductModel product;
  final VoidCallback onPress;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final bool hasVariants = product.productVariant.isNotEmpty;

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () {
          if (isAdmin || hasVariants) {
            onPress();
          }
        }, // Đã sửa để kiểm tra nếu isAdmin == true thì luôn có thể chọn
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: kSecondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return const Icon(Icons.error);
                        },
                      ),
                    ),
                  ),
                  if (!hasVariants) // Đã sửa để hiển thị khi isAdmin == true và không có variants
                    Container(
                      color: Colors.black
                          .withOpacity(0.5), // Màu nền cho thông báo
                      alignment: Alignment.center,
                      child: const Text(
                        "Sản phẩm chưa mở bán",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  if (product.isBestSeller == 1)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Bán chạy",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: Theme.of(context).textTheme.bodyText1,
              maxLines: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Đánh giá: ${product.rating.toStringAsFixed(1)}",
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: kPrimaryColor,
                  ),
                ),
                Text(
                  "Lượt bán: ${product.sold}",
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
