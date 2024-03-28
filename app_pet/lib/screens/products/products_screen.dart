import 'package:flutter/material.dart';
import 'package:shop_app/components/product_card.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/product.model.dart';
import 'package:shop_app/screens/home/components/search_field.dart';
import '../details/details_screen.dart';
import 'package:shop_app/services/api.dart';

class ProductsScreen extends StatefulWidget {
  final String? searchQuery;
  const ProductsScreen({super.key, this.searchQuery});

  static String routeName = "/products";

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<ProductModel>> productsFuture;

  @override
  void initState() {
    super.initState();

    productsFuture = Api.getAllProduct(searchQuery: widget.searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Danh sách sản phẩm",
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
        centerTitle: false,
        actions: <Widget>[
          // Sử dụng Spacer để đẩy SearchField về phía cuối (phải) của AppBar
          // Spacer(),
          // Giới hạn chiều rộng của SearchField bằng cách bọc nó trong SizedBox
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.8, // Ví dụ: chiếm 50% chiều rộng màn hình
              child: SearchField(),
            ),
          ),

          //Spacer(), // Sử dụng thêm một Spacer để giữ khoảng cách đều hai bên
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<List<ProductModel>>(
            future: productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Không có dữ liệu sản phẩm"));
              }
              final products = snapshot.data!;
              return GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) => ProductCard(
                  product: products[index],
                  onPress: () => Navigator.pushNamed(
                    context,
                    DetailsScreen.routeName,
                    arguments:
                        ProductDetailsArguments(product: products[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
