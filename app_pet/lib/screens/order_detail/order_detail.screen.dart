import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/components/icon_text_padding.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/CartItem.model.dart';
import 'package:shop_app/models/order.model.dart';
import 'package:shop_app/screens/order/order.screen.dart';
import 'package:shop_app/screens/preview_order/components/cart_order.componenr.dart';
import 'package:shop_app/services/api.dart';
// Giả sử bạn đã import CartOrder widget ở đây

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  static String routeName = "/order_detail";

  OrderDetailScreen({required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Future<OrderModel?>? orderDetail;

  @override
  void initState() {
    super.initState();
    orderDetail = Api.getDetailOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
      ),
      body: FutureBuilder<OrderModel?>(
        future: orderDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Có lỗi xảy ra. Vui lòng thử lại!'));
          } else if (snapshot.data == null) {
            return const Center(child: Text('Không tìm thấy đơn hàng'));
          } else {
            OrderModel order = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  const IconTextPadding(
                    icon: Icons.local_shipping,
                    text: 'Trạng thái đơn hàng ',
                    spacing: 16.0,
                  ),
                  const SizedBox(height: 10),
                  Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${order.status}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Ngày tạo đơn hàng: ${DateFormat('yyyy-MM-dd – kk:mm').format(order.orderCreatedDate)}',
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Ngày giao hàng dự kiến: ${DateFormat('yyyy-MM-dd – kk:mm').format(order.expectedShippingDate)}',
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Ngày giao hàng thực tế: ${DateFormat('yyyy-MM-dd – kk:mm').format(order.actualShippingDate)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const IconTextPadding(
                    icon: Icons.location_on,
                    text: 'Địa chỉ người nhận',
                    spacing: 16.0,
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Họ và tên: ${order.fullName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text('Số điện thoại: ${order.phoneNumber}'),
                          const SizedBox(height: 5),
                          Text(
                            'Địa chỉ: ${order.detailAddress}, ${order.ward}, ${order.district}, ${order.province}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const IconTextPadding(
                    icon: Icons.store,
                    text: 'Danh sách sản phẩm',
                    spacing: 16.0,
                  ),
                  const SizedBox(height: 10),
                  if (order.cartItems != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: order.cartItems!.map((cartItem) {
                        return CartOrder(
                          cartItem: cartItem,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 8.0),
                  IconTextPadding(
                    icon: order.paymentMethod == 'COD'
                        ? Icons.money
                        : // Cash icon
                        Icons.payment,
                    text:
                        'Phương thức thanh toán: ${order.paymentMethod ?? 'Chưa xác định'}',
                    spacing: 16.0,
                  ),
                  const SizedBox(height: 8.0),
                  const IconTextPadding(
                    icon: Icons.receipt,
                    text: 'Chi tiết hoá đơn',
                    spacing: 16.0,
                  ),
                  const SizedBox(height: 5.0),
                  IconTextPadding(
                    text: 'Tổng tiền hàng: đ${order.totalMoney} ',
                    spacing: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                  const SizedBox(height: 5.0),
                  IconTextPadding(
                    text: 'Tổng tiền phí vận chuyển: đ${order.feeShipping} ',
                    spacing: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                  const SizedBox(height: 5.0),
                  IconTextPadding(
                    text:
                        'Tổng thanh toán: đ${order.totalMoney + order.feeShipping} ',
                    spacing: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 5.0),
                  if (order.status == 'Chờ xác nhận')
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                                child: CircularProgressIndicator()),
                          );

                          print(widget.orderId);
                          String result = await Api.updateStatusOrder(
                              orderId: widget.orderId,
                              status: OrderStatusEnum.Cancel);

                          Navigator.pop(context);

                          if (result == "OK") {
                            showCustomDialog(
                              context,
                              "Đơn hàng",
                              "Đơn hàng đã được huỷ thành công",
                            );
                            await Future.delayed(const Duration(seconds: 3));
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              OrdersScreen.routeName,
                              (route) => false,
                            );
                          } else {
                            showCustomDialog(context, "Đơn hàng", result);
                          }
                        },
                        child: const Text('Huỷ đơn hàng'),
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
