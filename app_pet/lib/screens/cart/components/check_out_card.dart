import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';
import '../../../models/CartItem.model.dart'; // Giả sử bạn có một model CartItem như thế này

class CheckoutCard extends StatelessWidget {
  final List<CartItem> cartItems; // Danh sách các item được chọn
  const CheckoutCard({
    Key? key,
    required this.cartItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tính tổng tiền
    final total =
        cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
    // Tính tổng tiền khuyến mãi
    final promotion = cartItems.fold(
        0, (sum, item) => sum + (item.promotion * item.quantity));

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
                    onPressed: () {},
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
