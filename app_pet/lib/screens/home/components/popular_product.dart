import 'package:flutter/material.dart';
import 'package:shop_app/models/product.model.dart';
import 'package:shop_app/services/api.dart';

import '../../../components/product_card.dart';
import '../../details/details_screen.dart';
import '../../products/products_screen.dart';
import 'section_title.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({super.key});

  @override
  State<PopularProducts> createState() => _PopularProductsState();
}

class _PopularProductsState extends State<PopularProducts> {
  late Future<List<ProductModel>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture = Api.getAllProduct(is_best_seller: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: "Sản phẩm phổ biến",
            press: () {
              Navigator.pushNamed(context, ProductsScreen.routeName);
            },
          ),
        ),
        FutureBuilder<List<ProductModel>>(
          future: productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              var products = snapshot.data ?? [];
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    products.length,
                    (index) {
                      ProductModel product = products[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProductCard(
                          product: product,
                          onPress: () => Navigator.pushNamed(
                            context,
                            DetailsScreen.routeName,
                            arguments:
                                ProductDetailsArguments(product: product),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
