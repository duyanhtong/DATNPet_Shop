import 'package:flutter/material.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/constants.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:shop_app/models/Address.model.dart';
import 'package:shop_app/models/CartItem.model.dart';
import 'package:shop_app/screens/cart/cart_screen.dart';
import 'package:shop_app/screens/init_screen.dart';
import 'package:shop_app/screens/preview_order/order_preview.screen.dart';
import 'package:shop_app/services/api.dart';

class CheckoutPayPalPage extends StatefulWidget {
  final List<CartItem>? cartItems;
  final int? feeShipping;
  final int? addressId;
  final String? note;

  static String routeName = "/paypal";

  const CheckoutPayPalPage({
    Key? key,
    this.cartItems,
    this.feeShipping,
    this.addressId,
    this.note,
  }) : super(key: key);

  @override
  State<CheckoutPayPalPage> createState() => _CheckoutPayPalPageState();
}

class _CheckoutPayPalPageState extends State<CheckoutPayPalPage> {
  AddressModel? address;

  int flag = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAddress();
  }

  Future<void> fetchAddress() async {
    AddressModel? addressApi = await Api.getAddressById(widget.addressId!);
    if (addressApi != null) {
      setState(() {
        address = addressApi;
      });
    }
  }

  String feeShippingToUSD() {
    double totalInUSD = double.parse(calculateTotalInUSD());
    double totalMoney = double.parse(calculateTotalMoney());

    double feeShippingInUSD = totalInUSD - totalMoney;
    return feeShippingInUSD.toStringAsFixed(2);
  }

  String calculateTotalInUSD() {
    double totalPromotionInUSD = widget.cartItems!.fold(0,
        (sum, item) => sum + ((item.promotion * item.quantity) / exchangeRate));

    double totalItemsInUSD = widget.cartItems!.fold(
        0, (sum, item) => sum + ((item.price * item.quantity) / exchangeRate));

    double feeShippingInUSD = (widget.feeShipping ?? 0) / exchangeRate;

    double totalInUSD =
        totalItemsInUSD + feeShippingInUSD - totalPromotionInUSD;

    return totalInUSD.toStringAsFixed(2);
  }

  String calculateTotalMoney() {
    List<Map<String, dynamic>> itemsList = generateItemsList();

    double totalInUSD = itemsList.fold(0.0, (sum, item) {
      double priceInUSD = double.parse(item['price']);
      int quantity = int.parse(item['quantity']);
      return sum + (priceInUSD * quantity);
    });
    return totalInUSD.toStringAsFixed(2);
  }

  List<Map<String, dynamic>> generateItemsList() {
    return widget.cartItems!.map((item) {
      double priceInUSD = item.price / exchangeRate;

      String formattedPrice = priceInUSD.toStringAsFixed(2);

      return {
        "name": item.productVariantName,
        "quantity": item.quantity.toString(),
        "price": formattedPrice,
        "currency": "USD"
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thanh toán bằng PayPal",
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/mưa1.png',
              width: 420,
              height: 420,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Xác nhận thanh toán bằng PayPal',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  // Chờ đợi Navigator.push hoàn tất
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => PaypalCheckout(
                        sandboxMode: true,
                        clientId: clientIDPayPal,
                        secretKey: secretKeyPayPal,
                        returnURL: "success.snippetcoder.com",
                        cancelURL: "cancel.snippetcoder.com",
                        transactions: [
                          {
                            "amount": {
                              "total": calculateTotalInUSD(),
                              "currency": "USD",
                              "details": {
                                "subtotal": calculateTotalMoney(),
                                "shipping": feeShippingToUSD(),
                                "shipping_discount": 0,
                              },
                            },
                            "description":
                                "The payment transaction description.",
                            "item_list": {
                              "items": generateItemsList(),
                              "shipping_address": {
                                "recipient_name": address!.fullname,
                                "line1": address!.detailAddress,
                                "line2": "",
                                "city": address!.province,
                                "country_code": "VN",
                                "postal_code": "10000",
                                "phone": address!.phoneNumber,
                                "state": address!.district,
                              },
                            },
                          },
                        ],
                        note: "Contact us for any questions on your order.",
                        onSuccess: (Map params) async {
                          setState(() {
                            flag = 1;
                          });
                        },
                        onError: (error) {
                          setState(() {
                            flag = 0;
                          });
                          print("Lỗi nè 00000000000000000000000000");
                          print("onError: $error");
                          print("Lỗi nè 00000000000000000000000000");
                          Navigator.pop(context);
                        },
                        onCancel: () {
                          print("Huỷ nè 00000000000000000000000000");
                          print('cancelled:');
                          print("Huỷ nè 00000000000000000000000000");
                        },
                      ),
                    ),
                  );
                  if (flag == 1) {
                    setState(() {
                      isLoading = true;
                    });
                    List<int> cartIds =
                        widget.cartItems!.map((item) => item.id).toList();
                    final result = await Api.createOrder(
                      address_id: widget.addressId!,
                      carts: cartIds,
                      payment_method: "PAYPAL",
                    );
                    if (result == "OK") {
                      showCustomDialog(
                        context,
                        "Đặt hàng",
                        "Đơn hàng đã được đặt thành công",
                      );
                      await Future.delayed(Duration(seconds: 3));
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        InitScreen.routeName,
                        (route) => false,
                      );
                    } else {
                      showCustomDialog(context, "Đặt hàng", result);
                      await Future.delayed(Duration(seconds: 3));
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        OrderPreviewScreen.routeName,
                        (route) => false,
                      );
                    }
                    setState(() {
                      isLoading = false;
                    });
                  } else {
                    showCustomDialog(
                        context, "Thanh toán", "Thanh toán thất bại");

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      CartScreen.routeName,
                      (route) => false,
                    );
                    await Future.delayed(Duration(seconds: 3));
                  }
                },
                child: isLoading
                    ? CircularProgressIndicator()
                    : const Text('Tiếp tục thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
