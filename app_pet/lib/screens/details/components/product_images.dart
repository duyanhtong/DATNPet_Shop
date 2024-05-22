import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../models/product.model.dart'; // Đảm bảo đường dẫn này phù hợp với cấu trúc thư mục của bạn

class ProductImages extends StatefulWidget {
  const ProductImages({
    Key? key,
    required this.product,
    required this.selectedVariantIndex,
  }) : super(key: key);

  final ProductModel product;
  final int selectedVariantIndex;

  @override
  _ProductImagesState createState() => _ProductImagesState();
}

class _ProductImagesState extends State<ProductImages> {
  int selectedImageIndex = 0; // Đổi tên biến cho rõ ràng hơn

  @override
  void initState() {
    super.initState();

    selectedImageIndex = widget.selectedVariantIndex + 1;
  }

  @override
  void didUpdateWidget(covariant ProductImages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedVariantIndex != oldWidget.selectedVariantIndex) {
      setState(() {
        selectedImageIndex = widget.selectedVariantIndex + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePaths = [
      widget.product.imagePath,
      ...widget.product.productVariant.map((variant) => variant.imagePath)
    ];

    return Column(
      children: [
        SizedBox(
          width: 238,
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(imagePaths[
                selectedImageIndex]), // Sử dụng Image.network để tải hình ảnh từ URL
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              imagePaths.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    selectedImageIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: defaultDuration,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(8),
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: kPrimaryColor
                            .withOpacity(index == selectedImageIndex ? 1 : 0)),
                  ),
                  child: Image.network(
                    imagePaths[index],
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ), // Sử dụng Image.network để tải hình ảnh từ URL
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
