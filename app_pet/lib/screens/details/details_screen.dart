import 'package:flutter/material.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/product.model.dart';
import 'package:shop_app/models/product_variant.model.dart';
import 'package:shop_app/screens/cart/cart_screen.dart';
import 'package:shop_app/screens/cart/components/cart_icon_button.dart';
import 'package:shop_app/screens/details/components/product_review.dart';
import 'package:shop_app/screens/home/components/icon_btn_with_counter.dart';
import 'package:shop_app/services/api.dart';

import 'components/color_dots.dart';
import 'components/product_description.dart';
import 'components/product_images.dart';
import 'components/top_rounded_container.dart';

class DetailsScreen extends StatefulWidget {
  static String routeName = "/details";

  const DetailsScreen({
    Key? key,
  }) : super(key: key); // Update constructor

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TabBar(
                controller: _tabController,
                indicatorColor: kPrimaryColor,
                labelColor: kPrimaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  const Tab(text: 'Chi tiết'),
                  const Tab(text: 'Đánh giá'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: CartIconButton(),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(
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
          // This is the tab for Product Reviews
          ListProductReviewScreen(productId: args.product.id)
        ],
      ),
      bottomNavigationBar: TopRoundedContainer(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ElevatedButton(
              onPressed: () async {
                if (selectedVariantIndex != null) {
                  final selectedVariant =
                      product.productVariant[selectedVariantIndex!];
                  await handleAddToCart(selectedVariant.id, quantityToAdd);
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
