import 'package:flutter/material.dart';
import 'package:shop_app/models/product_variant.model.dart'; // Đảm bảo rằng đường dẫn đúng
import '../../../components/rounded_icon_btn.dart';
import '../../../constants.dart';
import '../../../models/product.model.dart';

class ColorDots extends StatefulWidget {
  final ProductModel product;
  final ValueChanged<ProductVariantModel> onSelectedVariant;
  final ValueChanged<int> onQuantityChanged;

  const ColorDots({
    Key? key,
    required this.product,
    required this.onSelectedVariant,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  _ColorDotsState createState() => _ColorDotsState();
}

class _ColorDotsState extends State<ColorDots> {
  int selectedVariant = 0;
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    // Lấy giá và tỷ lệ giảm giá của variant hiện tại
    final currentVariant = widget.product.productVariant[selectedVariant];
    final price = currentVariant.price;
    final discountRate = currentVariant.discountRate ?? 0; // Coi null là 0
    final totalPrice = price * quantity;
    final discountAmount =
        discountRate > 0 ? (totalPrice * discountRate) / 100 : 0;
    final totalPriceAfterDiscount = discountRate > 0
        ? totalPrice - discountAmount
        : totalPrice; // Chỉ áp dụng giảm giá nếu discountRate > 0

    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: Column(
        children: [
          Row(
            children: [
              ...List.generate(
                widget.product.productVariant.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVariant = index;
                      widget.onSelectedVariant(
                          widget.product.productVariant[index]);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 2),
                    padding: const EdgeInsets.all(8),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedVariant == index
                            ? kPrimaryColor
                            : Colors.transparent,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(
                            widget.product.productVariant[index].imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              RoundedIconBtn(
                icon: Icons.remove,
                press: () {
                  setState(() {
                    if (quantity > 1) {
                      quantity -= 1;
                      widget.onQuantityChanged(quantity);
                    }
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  quantity.toString(),
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              RoundedIconBtn(
                icon: Icons.add,
                showShadow: true,
                press: () {
                  setState(() {
                    quantity += 1;
                    widget.onQuantityChanged(quantity);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              if (discountRate > 0) // Chỉ hiển thị nếu có giảm giá
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tổng tiền: đ${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '-    Giảm giá: đ${discountAmount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ],
                ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tổng sau giảm: đ${totalPriceAfterDiscount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16.0, color: kPrimaryColor),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
