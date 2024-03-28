import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/CartItem.model.dart';
import 'package:shop_app/services/api.dart';

import '../../models/Cart.dart';
import 'components/cart_card.dart';
import 'components/check_out_card.dart';

class CartScreen extends StatefulWidget {
  static String routeName = "/cart";

  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartItem>> cartItemsFuture;
  Map<int, bool> itemSelected = {};
  List<CartItem> selectedCartItems = [];

  @override
  void initState() {
    super.initState();
    cartItemsFuture = Api.getListCartItem();
    cartItemsFuture.then((cartItems) {
      setState(() {
        cartItems.forEach((item) {
          itemSelected[item.productVariantId] = false;
        });
      });
    });
  }

  void updateSelectedItems(List<CartItem> cartItems) {
    setState(() {
      selectedCartItems = cartItems
          .where((item) => itemSelected[item.productVariantId] == true)
          .toList();
    });
    //fetchCartItems();
    print(cartItems);
  }

  void fetchCartItems() {
    cartItemsFuture = Api.getListCartItem();
    cartItemsFuture.then((cartItems) {
      setState(() {
        // itemSelected.clear();
        // cartItems.forEach((item) {
        //   itemSelected[item.productVariantId] = false;
        // });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: const [
            Text(
              "Giỏ hàng của bạn",
              style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder<List<CartItem>>(
          future: cartItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("An error occurred!"));
            } else if (snapshot.hasData) {
              final cartItems = snapshot.data!;
              if (itemSelected.isEmpty) {
                cartItems.forEach((item) {
                  itemSelected[item.productVariantId] = false;
                });
              }
              // Lọc danh sách các item đã chọn
              final selectedCartItems = cartItems
                  .where((item) => itemSelected[item.productVariantId] == true)
                  .toList();
              return ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Dismissible(
                      key: Key(item.productVariantId.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          cartItems.removeAt(index);
                          itemSelected.remove(item.productVariantId);
                          updateSelectedItems(cartItems);
                        });
                      },
                      background: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE6E6),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Spacer(),
                            SvgPicture.asset("assets/icons/Trash.svg"),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: itemSelected[item.productVariantId],
                            onChanged: (bool? newValue) {
                              setState(() {
                                itemSelected[item.productVariantId] = newValue!;
                                updateSelectedItems(cartItems);
                              });
                            },
                          ),
                          Expanded(
                            child: CartCard(cartItem: item),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                  child: Text("Không có sản phẩm nào trong giỏ hàng."));
            }
          },
        ),
      ),
      // Sửa lại phần này để truyền danh sách các item đã chọn vào CheckoutCard
      bottomNavigationBar: CheckoutCard(cartItems: selectedCartItems),
    );
  }
}
