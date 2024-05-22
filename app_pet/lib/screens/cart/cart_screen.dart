import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/CartItem.model.dart';
import 'package:shop_app/services/api.dart';

import 'components/cart_card.dart';
import 'components/check_out_card.dart';

class CartScreen extends StatefulWidget {
  static String routeName = "/cart";

  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartItem>> cartItemsFuture;
  List<CartItem> cartItems = [];
  Map<int, bool> itemSelected = {};
  List<CartItem> selectedCartItems = [];
  bool _isLoading = false;
  int currentPage = 1;
  bool _isFetchingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    loadCartItems();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isFetchingMore) {
      currentPage++;
      loadCartItems(isFetchingMore: true);
    }
  }

  Future<void> loadCartItems({bool isFetchingMore = false}) async {
    if (!_isLoading || (isFetchingMore && !_isFetchingMore)) {
      if (isFetchingMore) {
        setState(() => _isFetchingMore = true);
      } else {
        setState(() => _isLoading = true);
      }
      try {
        final List<CartItem> newCartItems =
            await Api.getListCartItem(page: currentPage);
        setState(() {
          if (isFetchingMore) {
            cartItems.addAll(newCartItems);
          } else {
            cartItems = newCartItems;
          }
          updateSelectedItems();
        });
      } catch (error) {
        debugPrint('Failed to load more cartItem: $error');
      } finally {
        setState(() {
          if (isFetchingMore) {
            _isFetchingMore = false;
          } else {
            _isLoading = false;
          }
        });
      }
    }
  }

  Future<void> updateQuantity(int quantity, int cartId) async {
    if (quantity > 0) {
      setState(() {
        _isLoading = true;
      });
      try {
        String message = await Api.updateCart(cartId, quantity);
        if (message == "OK") {
          setState(() {
            cartItems = cartItems.map((item) {
              if (item.id == cartId) {
                return item.copyWith(quantity: quantity);
              }
              return item;
            }).toList();
            updateSelectedItems();
          });
        } else {
          showCustomDialog(context, "Giỏ hàng", message);
        }
      } catch (error) {
        showCustomDialog(context, "Error", error.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Handle when quantity is 0 or negative (e.g., remove the product)
    }
  }

  void updateSelectedItems() {
    setState(() {
      selectedCartItems = cartItems
          .where((item) => itemSelected[item.productVariantId] == true)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              "Giỏ hàng của bạn",
              style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
            ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : cartItems.isEmpty
                ? const Center(
                    child: Text("Không có sản phẩm nào trong giỏ hàng."))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: cartItems.length + (_isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == cartItems.length && _isFetchingMore) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: kPrimaryColor));
                      }
                      final item = cartItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Dismissible(
                          key: Key(item.id.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) async {
                            final result = await Api.removeCart(item.id);
                            if (result == "OK") {
                              setState(() {
                                cartItems.removeAt(index);
                                itemSelected.remove(item.productVariantId);
                                updateSelectedItems();
                              });
                            } else {
                              showCustomDialog(context, "Giỏ hàng", result);
                            }
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
                                value: itemSelected[item.productVariantId] ??
                                    false,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    itemSelected[item.productVariantId] =
                                        newValue ?? false;
                                    updateSelectedItems();
                                  });
                                },
                              ),
                              Expanded(
                                child: CartCard(
                                  cartItem: item,
                                  onUpdateQuantity: (quantity) =>
                                      updateQuantity(quantity, item.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
      ),
      bottomNavigationBar: AnimatedOpacity(
        opacity: _isLoading ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: _isLoading
            ? const CircularProgressIndicator()
            : CheckoutCard(
                key: ValueKey(
                    selectedCartItems.length), // Sử dụng ValueKey ở đây
                cartItems: selectedCartItems,
              ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
