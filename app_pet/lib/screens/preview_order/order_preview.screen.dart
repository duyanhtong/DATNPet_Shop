// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shop_app/components/icon_text_padding.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/Address.model.dart';

import 'package:shop_app/screens/addresses/list-address.screen.dart';

import 'package:shop_app/screens/preview_order/components/address_default.component.dart';
import 'package:shop_app/screens/preview_order/components/cart_order.componenr.dart';
import 'package:shop_app/screens/preview_order/components/check-out-order.component.dart';

import 'package:shop_app/services/api.dart';
import '../../../models/CartItem.model.dart';

class OrderPreviewScreen extends StatefulWidget {
  static String routeName = "/order_preview";

  final List<CartItem>? cartItems;

  const OrderPreviewScreen({Key? key, this.cartItems}) : super(key: key);

  @override
  _OrderPreviewScreenState createState() => _OrderPreviewScreenState();
}

class _OrderPreviewScreenState extends State<OrderPreviewScreen> {
  AddressModel? defaultAddress;
  int? feeShipping;

  String? _selectedPaymentMethod;
  final List<DropdownMenuItem<String>> _paymentMethods = [
    const DropdownMenuItem(
      value: 'COD',
      child: Text('COD'),
    ),
    const DropdownMenuItem(
      value: 'ONLINE',
      child: Text('PAYPAL'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getDefaultAddress();
    _calculateFeeShipping();
    _selectedPaymentMethod = _paymentMethods[0].value;
  }

  Future<void> _getDefaultAddress() async {
    try {
      AddressModel? address = await Api.getDefaultAddress();
      if (mounted) {
        setState(() {
          defaultAddress = address;
        });
      }
    } catch (error) {
      debugPrint('Failed to load default address: $error');
    } finally {
      if (defaultAddress == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không tìm thấy địa chỉ mặc định. Vui lòng thêm địa chỉ mới.',
            ),
            backgroundColor: kPrimaryColor,
          ),
        );
      }
    }
  }

  Future<void> _calculateFeeShipping() async {
    await _getDefaultAddress();
    if (defaultAddress != null && widget.cartItems != null) {
      try {
        List<int> cartIds = widget.cartItems!.map((item) => item.id).toList();

        int? feeShippingApi = await Api.calculateFeeShipping(
          addressId: defaultAddress!.id,
          cartIds: cartIds,
        );
        if (mounted) {
          setState(() {
            feeShipping = feeShippingApi;
          });
        }
      } catch (error) {
        debugPrint('Failed to load fee shipping: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Lỗi tính toán phí vận chuyển. Vui lòng thử lại.',
              ),
              backgroundColor: kPrimaryColor,
            ),
          );
        }
      }
    }
  }

  void _onAddressSelected() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListAddressScreen()),
    ).then((_) {
      if (mounted) {
        _getDefaultAddress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const IconTextPadding(
              icon: Icons.location_on,
              text: 'Địa chỉ người nhận',
              spacing: 16.0,
            ),
            if (defaultAddress != null)
              AddressCard(
                address: defaultAddress!,
                onSelected: _onAddressSelected,
              ),
            const IconTextPadding(
              icon: Icons.store,
              text: 'Cửa hàng Mưa Pet',
              spacing: 16.0,
            ),
            const SizedBox(height: 10),
            if (widget.cartItems != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.cartItems!.map((cartItem) {
                  return CartOrder(
                    cartItem: cartItem,
                  );
                }).toList(),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      IconTextPadding(
                        icon: Icons.credit_card,
                        text: 'Phương thức thanh toán: ',
                        spacing: 16.0,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8.0),
                  DropdownButton<String>(
                    value: _selectedPaymentMethod,
                    elevation: 16,
                    style: const TextStyle(color: kPrimaryColor),
                    onChanged: (String? newValue) {
                      if (mounted) {
                        setState(() {
                          _selectedPaymentMethod = newValue;
                        });
                      }
                    },
                    items: _paymentMethods,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1.0),
            if (feeShipping != null)
              IconTextPadding(
                icon: Icons.local_shipping,
                text: 'Phí vận chuyển: ${feeShipping!} vnđ',
                spacing: 16.0,
              ),
            if (feeShipping == null)
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8.0),
            const IconTextPadding(
              icon: Icons.receipt,
              text: 'Chi tiết hoá đơn',
              spacing: 16.0,
            ),
            const SizedBox(height: 8.0),
            IconTextPadding(
              text: 'Tổng tiền hàng: đ${calculateTotalPrice()} ',
              spacing: 16.0,
              fontWeight: FontWeight.normal,
            ),
            IconTextPadding(
              text: 'Tổng tiền phí vận chuyển: đ${(feeShipping ?? 0)} ',
              spacing: 16.0,
              fontWeight: FontWeight.normal,
            ),
            IconTextPadding(
              text: 'Tổng tiền giảm giá: - đ${calculateTotalPromotion()} ',
              spacing: 16.0,
              fontWeight: FontWeight.normal,
            ),
            IconTextPadding(
              text:
                  'Tổng thanh toán: đ${calculateTotalPrice() - calculateTotalPromotion() + (feeShipping ?? 0)} ',
              spacing: 16.0,
            ),
          ],
        ),
      ),
      bottomNavigationBar: defaultAddress != null
          ? CheckOutOrder(
              cartItems: widget.cartItems!,
              feeShipping: feeShipping,
              addressId: defaultAddress!.id,
              payment_method: _selectedPaymentMethod!,
            )
          : const SizedBox(),
    );
  }

  int calculateTotalPrice() {
    int totalPrice = 0;
    if (widget.cartItems != null) {
      for (CartItem item in widget.cartItems!) {
        totalPrice += item.price * item.quantity;
      }
    }
    return totalPrice;
  }

  int calculateTotalPromotion() {
    int totalPromotion = 0;
    if (widget.cartItems != null) {
      for (CartItem item in widget.cartItems!) {
        totalPromotion += item.promotion * item.quantity;
      }
    }
    return totalPromotion;
  }
}
