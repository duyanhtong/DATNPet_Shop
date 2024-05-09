import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/models/product.model.dart';

import 'package:shop_app/models/product_variant.model.dart';
import 'package:shop_app/services/api.dart';

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

  Future<void> createWishList(int productId) async {
    String responseMessage = await Api.addProductToWishList(productId);
    showCustomDialog(context, "Danh sách mong muốn", responseMessage);
  }

  @override
  void initState() {
    super.initState();
    currentVariant = widget.product.productVariant[widget.selectedVariantIndex];
    checkProductInWishList();
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

  Future<void> checkProductInWishList() async {
    bool isInWishList = await Api.checkProductToWishList(widget.product.id);

    setState(() {
      _isFavorited = isInWishList;
    });
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
            style: const TextStyle(fontSize: 18),
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
                    child: const Row(
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
                      color: _isFavorited ? kPrimaryColor : Colors.grey[300],
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorited = !_isFavorited;
                        createWishList(widget.product.id);
                      });
                    },
                  ),
                ],
              ),
              if (_isDescriptionVisible)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // Căn chiều ngang để các Text chiếm đầy chiều rộng
                    children: [
                      const Text(
                        "Mô tả sản phẩm :\n",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.justify,
                      ),
                      Text(
                        "${widget.product.description} \n",
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.justify,
                      ),
                      const Text(
                        "Xuất Xứ: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.justify,
                      ),
                      Text(
                        "${widget.product.origin} \n",
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.justify,
                      ),
                      const Text(
                        "Thành phần: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.justify,
                      ),
                      Text(
                        "${widget.product.ingredient} \n",
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.justify,
                      ),
                      const Text(
                        "Thương hiệu: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        textAlign: TextAlign.justify,
                      ),
                      Text(
                        "${widget.product.brand} \n",
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Text('\đ${discountedPrice.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (discountRate > 0) ...[
              const SizedBox(width: 10),
              Text('-${discountRate}%',
                  style: const TextStyle(
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
