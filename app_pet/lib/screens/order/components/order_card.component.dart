// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/order.model.dart';
import 'package:shop_app/screens/ProductReview/product_review.screen.dart';
import 'package:shop_app/screens/order_detail/order_detail.screen.dart';
import 'package:shop_app/services/api.dart';

class OrderCard extends StatefulWidget {
  final OrderModel order;
  final bool isAdmin;
  final String nameTab;
  final bool isReview;
  final VoidCallback? onOrderConfirmed;

  const OrderCard({
    Key? key,
    required this.order,
    this.isAdmin = false,
    this.onOrderConfirmed,
    required this.nameTab,
    this.isReview = false,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  @override
  Widget build(BuildContext context) {
    final cartItemCount = widget.order.cartItems.fold<int>(
        0, (previousValue, cartItem) => previousValue + cartItem.quantity);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: widget.order.id),
          ),
        ).then((_) => widget.onOrderConfirmed?.call());
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order.cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = widget.order.cartItems[index];
                return ListTile(
                  title: Text(
                    '${cartItem.productName} (${cartItem.productVariantName})',
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'đ ${cartItem.price - cartItem.promotion}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        ' (đ ${cartItem.promotion})',
                        style: const TextStyle(
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Số lượng: ${cartItem.quantity}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  leading: Image.network(
                    cartItem.image,
                    width: 50,
                    height: 50,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ),
                );
              },
            ),
            widget.isAdmin
                ? adminView(cartItemCount, widget.nameTab, widget.isAdmin)
                : userView(cartItemCount, widget.nameTab, widget.order.status,
                    context),
          ],
        ),
      ),
    );
  }

  Widget userView(
    int cartItemCount,
    String nameTab,
    String status,
    BuildContext context,
  ) {
    if (nameTab == OrderStatusEnum.Delivered &&
        !widget.isAdmin &&
        widget.order.status == OrderStatusEnum.Delivered) {
      if (widget.isReview) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  widget.order.status.statusIcon,
                  const SizedBox(width: 4),
                  Text(
                    widget.order.status,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.order.status.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Tổng cộng($cartItemCount Sản phẩm): đ ${calculateTotalPrice() + widget.order.feeShipping}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Đã đánh giá',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                widget.order.status.statusIcon,
                const SizedBox(width: 4),
                Text(
                  widget.order.status,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.order.status.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Tổng cộng($cartItemCount Sản phẩm): đ ${calculateTotalPrice() + widget.order.feeShipping}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                IntrinsicWidth(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProductReviewScreen(order: widget.order)),
                      ).then((_) => widget.onOrderConfirmed?.call());
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.5),
                      child: Text("Đánh giá", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                widget.order.status.statusIcon,
                const SizedBox(width: 4),
                Text(
                  widget.order.status,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.order.status.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text(
                      'Tổng cộng($cartItemCount Sản phẩm): đ ${calculateTotalPrice() + widget.order.feeShipping}',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget adminView(int cartItemCount, String nameTab, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              widget.order.status.statusIcon,
              const SizedBox(width: 4),
              Text(
                widget.order.status,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.order.status.statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Tổng cộng($cartItemCount Sản phẩm): đ ${calculateTotalPrice() + widget.order.feeShipping}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              if (isAdmin &&
                  (nameTab == OrderStatusEnum.PendingConfirmation ||
                      nameTab == OrderStatusEnum.WaitingForDelivery))
                IntrinsicWidth(
                  child: ElevatedButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      String result;
                      if (nameTab == OrderStatusEnum.WaitingForDelivery) {
                        result = await Api.updateStatusOrder(
                            orderId: widget.order.id,
                            status: OrderStatusEnum.Delivered);
                      } else {
                        result = await Api.updateStatusOrder(
                            orderId: widget.order.id,
                            status: OrderStatusEnum.ReadyToPick);
                      }
                      Navigator.pop(context);

                      if (result == "OK") {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Đơn hàng"),
                              content: Text(
                                nameTab == OrderStatusEnum.WaitingForDelivery
                                    ? "Đơn hàng đã hoàn thành thành công"
                                    : "Đơn hàng đã được xác nhận thành công",
                              ),
                            );
                          },
                        );

                        await Future.delayed(const Duration(seconds: 2));
                        Navigator.pop(context);
                        widget.onOrderConfirmed?.call();
                      } else {
                        showCustomDialog(context, "Đơn hàng", result);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.5),
                      child: Text(
                          nameTab == "Chờ giao hàng"
                              ? 'Hoàn thành'
                              : 'Xác nhận',
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  int calculateTotalPrice() {
    int totalPrice = 0;
    for (final cartItem in widget.order.cartItems) {
      totalPrice += (cartItem.price - cartItem.promotion) * cartItem.quantity;
    }
    return totalPrice;
  }
}
