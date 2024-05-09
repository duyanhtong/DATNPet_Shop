import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/screens/preview_order/order_preview.screen.dart';
import '../../../constants.dart';
import '../../../models/CartItem.model.dart';

class CheckoutCard extends StatefulWidget {
  final List<CartItem> cartItems;
  const CheckoutCard({
    Key? key,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<CheckoutCard> createState() => _CheckoutCardState();
}

class _CheckoutCardState extends State<CheckoutCard> {
  @override
  Widget build(BuildContext context) {
    final total = widget.cartItems
        .fold(0, (sum, item) => sum + (item.price * item.quantity));

    final promotion = widget.cartItems
        .fold(0, (sum, item) => sum + (item.promotion * item.quantity));

    return Container(
      padding: const EdgeInsets.all(18.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: "Tổng thanh toán:\n",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: " \đ$total",
                          style: TextStyle(
                            fontSize: 16,
                            color: kPrimaryColor,
                          ),
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              "\đ$promotion",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderPreviewScreen(cartItems: widget.cartItems),
                        ),
                      );
                    },
                    child: const Text("Mua hàng"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
