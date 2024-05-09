import 'package:flutter/material.dart';
import 'package:shop_app/components/product_card.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/product.model.dart';
import 'package:shop_app/models/wish_list.model.dart';
import 'package:shop_app/services/api.dart';
import '../details/details_screen.dart';

class FavoriteScreen extends StatefulWidget {
  static String routeName = "/favorite";
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<WishListModel>> wishListsFuture;

  @override
  void initState() {
    super.initState();
    wishListsFuture = Api.getAllWishList().then((data) {
      print("Data received: $data");
      return data;
    }).catchError((error) {
      print("Error fetching data: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Danh sách sản phẩm yêu thích",
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<List<WishListModel>>(
            future: wishListsFuture,
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
              final wishLists = snapshot.data!;

              return GridView.builder(
                itemCount: wishLists.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final product = wishLists[index].product;
                  return ProductCard(
                    product: product,
                    onPress: () => Navigator.pushNamed(
                      context,
                      DetailsScreen.routeName,
                      arguments: ProductDetailsArguments(product: product),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
