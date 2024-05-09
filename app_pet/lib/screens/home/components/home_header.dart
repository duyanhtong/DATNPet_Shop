import 'package:flutter/material.dart';
import 'package:shop_app/screens/cart/components/cart_icon_button.dart';
import 'package:shop_app/services/api.dart';

import '../../cart/cart_screen.dart';
import 'icon_btn_with_counter.dart';
import 'search_field.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
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
      setState(() {
        // _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: SearchField()),
          const SizedBox(width: 16),
          const CartIconButton(),
          const SizedBox(width: 8),
          IconBtnWithCounter(
            svgSrc: "assets/icons/Bell.svg",
            numOfitem: 3,
            press: () {},
          ),
        ],
      ),
    );
  }
}
