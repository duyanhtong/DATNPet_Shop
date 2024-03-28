import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/product.model.dart';

import 'package:shop_app/models/product_variant.model.dart';
import 'package:shop_app/screens/cart/cart_screen.dart';
import 'package:shop_app/screens/home/components/icon_btn_with_counter.dart';
import 'package:shop_app/services/api.dart';

import 'components/color_dots.dart';
import 'components/product_description.dart';
import 'components/product_images.dart';
import 'components/top_rounded_container.dart';

class DetailsScreen extends StatefulWidget {
  static String routeName = "/details";

  const DetailsScreen({super.key});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int selectedVariantIndex = 0;
  int quantityToAdd = 1;

  Future<void> handleAddToCart(int productVariantId, int quantity) async {
    String responseMessage =
        await Api.addProductToCart(productVariantId, quantity);
    showCustomDialog(context, "Giỏ hàng", responseMessage);
  }

  void handleQuantityChanged(int quantity) {
    setState(() {
      quantityToAdd = quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProductDetailsArguments args =
        ModalRoute.of(context)!.settings.arguments as ProductDetailsArguments;
    final product = args.product;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        title: const Text(
          "Chi tiết sản phẩm",
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconBtnWithCounter(
              svgSrc: "assets/icons/Cart Icon.svg",
              press: () => Navigator.pushNamed(context, CartScreen.routeName),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          ProductImages(
            product: product,
            selectedVariantIndex: selectedVariantIndex ?? 0,
          ),
          TopRoundedContainer(
            color: Colors.white,
            child: Column(
              children: [
                ProductDescription(
                  product: product,
                  pressOnSeeMore: () {},
                  selectedVariantIndex: selectedVariantIndex ?? 0,
                ),
                const SizedBox(
                  height: 5.0,
                ),
                TopRoundedContainer(
                  color: const Color(0xFFF6F7F9),
                  child: Column(
                    children: [
                      ColorDots(
                        product: product,
                        onQuantityChanged: handleQuantityChanged,
                        onSelectedVariant: (ProductVariantModel variant) {
                          setState(() {
                            selectedVariantIndex =
                                product.productVariant.indexOf(variant);
                          });
                          print("Variant ${variant.name} selected");
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: TopRoundedContainer(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ElevatedButton(
              onPressed: () {
                if (selectedVariantIndex != null) {
                  final selectedVariant =
                      product.productVariant[selectedVariantIndex!];
                  handleAddToCart(selectedVariant.id, quantityToAdd);
                } else {
                  showCustomDialog(context, "Giỏ hàng",
                      "Vui lòng chọn một biến thể sản phẩm.");
                }
              },
              child: const Text("Thêm vào giỏ hàng"),
            ),
          ),
        ),
      ),
    );
  }
}

class ProductDetailsArguments {
  final ProductModel product;

  ProductDetailsArguments({required this.product});
}
