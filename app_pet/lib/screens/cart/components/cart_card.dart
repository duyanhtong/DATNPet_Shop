import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/models/product.model.dart';
import 'package:shop_app/screens/details/details_screen.dart';
import 'package:shop_app/services/api.dart';
import '../../../constants.dart';
import '../../../models/CartItem.model.dart';

class CartCard extends StatefulWidget {
  final CartItem cartItem;
  final Function(int quantity) onUpdateQuantity;

  const CartCard({
    Key? key,
    required this.cartItem,
    required this.onUpdateQuantity,
  }) : super(key: key);

  @override
  _CartCardState createState() => _CartCardState();
}

class _CartCardState extends State<CartCard> {
  late int _quantity;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _quantity = widget.cartItem.quantity;
  }

  void _updateQuantity(bool isIncrement) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (isIncrement) {
        _quantity++;
      } else {
        if (_quantity > 1) {
          _quantity--;
        }
      }
      await Api.updateCart(widget.cartItem.id, _quantity); // 비동기 호출로 변경
      widget.onUpdateQuantity(_quantity);
    } catch (error) {
      showCustomDialog(context, "Giỏ hàng", error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? CircularProgressIndicator() : _buildCartCard(context);
  }

  @override
  Widget _buildCartCard(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            ProductModel product = await Api.getProductByProductVariantId(
                widget.cartItem.productVariantId);
            Navigator.pushNamed(
              context,
              DetailsScreen.routeName,
              arguments: ProductDetailsArguments(product: product),
            );
          },
          child: SizedBox(
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
                    widget.cartItem.image,
                    fit: BoxFit.cover,
                  ),
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
                widget.cartItem.productName,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.cartItem.productVariantName.isNotEmpty)
                Text(
                  widget.cartItem.productVariantName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 1, // Giới hạn số dòng
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      text: "\đ${widget.cartItem.price}",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: kPrimaryColor),
                      children: [
                        if (widget.cartItem.promotion > 0)
                          TextSpan(
                            text: " \đ${widget.cartItem.promotion}",
                            style: TextStyle(
                                color: Colors.grey[800],
                                decoration: TextDecoration.lineThrough),
                          ),
                      ],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () => {_updateQuantity(false)},
                  ),
                  Text(
                    "$_quantity",
                    style: TextStyle(color: kPrimaryColor),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _updateQuantity(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
