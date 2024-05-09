import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/screens/checkout/paypal.screen.dart';
import 'package:shop_app/screens/init_screen.dart';
import 'package:shop_app/screens/preview_order/order_preview.screen.dart';
import 'package:shop_app/services/api.dart';
import '../../../constants.dart';
import '../../../models/CartItem.model.dart';

class CheckOutOrder extends StatefulWidget {
  final List<CartItem> cartItems;
  final int? feeShipping;
  final int addressId;
  final String payment_method;
  const CheckOutOrder(
      {Key? key,
      required this.cartItems,
      this.feeShipping,
      required this.addressId,
      required this.payment_method})
      : super(key: key);

  @override
  State<CheckOutOrder> createState() => _CheckOutOrderState();
}

class _CheckOutOrderState extends State<CheckOutOrder> {
  bool _isProcessing = false;

  Future<void> _handleOrder() async {
    setState(() {
      _isProcessing = true;
    });

    if (widget.payment_method == "COD") {
      List<int> cartIds = widget.cartItems.map((item) => item.id).toList();
      final result = await Api.createOrder(
        address_id: widget.addressId,
        carts: cartIds,
        payment_method: widget.payment_method,
      );

      if (result == "OK") {
        showCustomDialog(
          context,
          "Đặt hàng",
          "Đơn hàng đã được đặt thành công",
        );
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushNamedAndRemoveUntil(
          context,
          InitScreen.routeName,
          (route) => false,
        );
      } else {
        showCustomDialog(context, "Đặt hàng", result);
      }
    } else if (widget.payment_method == "ONLINE") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPayPalPage(
            cartItems: widget.cartItems,
            feeShipping: widget.feeShipping,
            addressId: widget.addressId,
          ),
        ),
      );
    }

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final promotion = widget.cartItems
        .fold(0, (sum, item) => sum + (item.promotion * item.quantity));
    final total = widget.cartItems
            .fold(0, (sum, item) => sum + (item.price * item.quantity)) +
        (widget.feeShipping ?? 0) -
        promotion;

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
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: " \đ$total",
                          style: const TextStyle(
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
                              style: const TextStyle(
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
                    onPressed: _isProcessing ? null : _handleOrder,
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kPrimaryColor),
                            ),
                          )
                        : const Text("Đặt hàng"),
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
