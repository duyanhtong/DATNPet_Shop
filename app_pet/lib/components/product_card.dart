import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/models/product.model.dart'; // Import ProductModel 클래스
import '../constants.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    this.width = 140,
    this.aspectRatio = 1.02,
    required this.product,
    required this.onPress,
  }) : super(key: key);

  final double width, aspectRatio;
  final ProductModel product;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: kSecondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          Image.network(product.imagePath, fit: BoxFit.cover),
                    ),
                  ),
                  // Thêm Positioned widget để định vị chữ "Bán chạy"
                  if (product.isBestSeller == 1)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
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
                  style: TextStyle(
                    fontSize: 9.5,
                    color: kPrimaryColor,
                  ),
                ),
                Text(
                  "Lượt bán: ${product.sold}",
                  style: TextStyle(
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
