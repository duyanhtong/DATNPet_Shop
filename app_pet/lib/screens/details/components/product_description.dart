import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/models/product.model.dart';

import 'package:shop_app/models/product_variant.model.dart';

import '../../../constants.dart';

class ProductDescription extends StatefulWidget {
  final ProductModel product;
  final GestureTapCallback? pressOnSeeMore;
  final int selectedVariantIndex;

  const ProductDescription({
    Key? key,
    required this.product,
    this.pressOnSeeMore,
    required this.selectedVariantIndex,
  }) : super(key: key);

  @override
  _ProductDescriptionState createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  late ProductVariantModel currentVariant;
  bool _isDescriptionVisible = false;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    currentVariant = widget.product.productVariant[widget.selectedVariantIndex];
  }

  @override
  void didUpdateWidget(ProductDescription oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedVariantIndex != oldWidget.selectedVariantIndex) {
      setState(() {
        currentVariant =
            widget.product.productVariant[widget.selectedVariantIndex];
      });
    }
  }

  void updateVariant(ProductVariantModel variant) {
    setState(() {
      currentVariant = variant;
    });
  }

  @override
  Widget build(BuildContext context) {
    final price = currentVariant.price;
    final discountRate = currentVariant.discountRate ?? 0;
    final discountedPrice =
        discountRate > 0 ? price - (price * discountRate / 100) : price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            widget.product.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        // Variant
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Phân loại: ${currentVariant.name}',
            style: TextStyle(fontSize: 18),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionVisible = !_isDescriptionVisible;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          "Mô tả sản phẩm",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: kPrimaryColor),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: kPrimaryColor,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      // Sử dụng trạng thái _isFavorited để kiểm soát màu sắc
                      color: _isFavorited
                          ? kPrimaryColor
                          : Colors.grey[
                              300], // Colors.grey[300] là màu cho viền, bạn có thể điều chỉnh nếu cần
                      // Nếu muốn chỉ đổi viền thì có thể sử dụng Icons.favorite_border thay vì thay đổi màu sắc
                    ),
                    onPressed: () {
                      setState(() {
                        // Đảo ngược trạng thái khi được nhấn
                        _isFavorited = !_isFavorited;
                        // Nếu cần, gọi _callApi ở đây
                      });
                    },
                  ),
                ],
              ),
              if (_isDescriptionVisible)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.product
                        .description, // Giả định cách truy cập mô tả sản phẩm
                    style: TextStyle(color: Colors.black),
                  ),
                ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Text('\đ${discountedPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (discountRate > 0) ...[
              SizedBox(width: 10),
              Text('-${discountRate}%',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor)),
            ],
          ]),
        ),
      ],
    );
  }
}
