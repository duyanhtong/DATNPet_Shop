import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/services/api.dart';
import '../../../constants.dart';
import '../../../models/CartItem.model.dart';

class CartOrder extends StatelessWidget {
  final CartItem cartItem;
  final double horizontalPadding;

  const CartOrder({
    Key? key,
    required this.cartItem,
    this.horizontalPadding = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          SizedBox(
            width: screenWidth * 0.15,
            child: AspectRatio(
              aspectRatio: 0.88,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F9),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Image.network(
                    cartItem.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.productName,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (cartItem.productVariantName.isNotEmpty)
                  Text(
                    cartItem.productVariantName,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Số lượng: ${cartItem.quantity}",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Spacer(), // Đẩy giá tiền về phía bên phải
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text.rich(
                        TextSpan(
                          text: "\đ${cartItem.price}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: kPrimaryColor),
                          children: [
                            if (cartItem.promotion > 0)
                              TextSpan(
                                text: " \đ${cartItem.promotion}",
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    decoration: TextDecoration.lineThrough),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
