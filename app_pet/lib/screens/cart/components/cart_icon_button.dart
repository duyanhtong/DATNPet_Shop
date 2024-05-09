import 'package:flutter/material.dart';
import 'package:shop_app/screens/home/components/icon_btn_with_counter.dart';
import 'package:shop_app/services/api.dart';
import '../../cart/cart_screen.dart';

class CartIconButton extends StatefulWidget {
  const CartIconButton({Key? key}) : super(key: key);

  @override
  _CartIconButtonState createState() => _CartIconButtonState();
}

class _CartIconButtonState extends State<CartIconButton> {
  int totalCart = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCartItems();
  }

  Future<void> loadCartItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final cartCount = await Api.countCartItem();
      setState(() {
        totalCart = cartCount > 99 ? 99 : cartCount;
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading cart items: $error');
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : IconBtnWithCounter(
            svgSrc: "assets/icons/Cart Icon.svg",
            numOfitem: totalCart,
            press: () async {
              await Navigator.pushNamed(context, CartScreen.routeName);
              loadCartItems();
            },
          );
  }
}
