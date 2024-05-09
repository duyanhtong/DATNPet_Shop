import 'package:shop_app/models/CartItem.model.dart';

class OrderModel {
  final int id;
  final int userId;
  final String fullName;
  final String phoneNumber;
  final String? note;
  final String status;
  final String paymentMethod;
  final int totalMoney;
  final int feeShipping;
  final String province;
  final String district;
  final String ward;
  final String detailAddress;
  final DateTime expectedShippingDate;
  final DateTime actualShippingDate;
  final DateTime orderCreatedDate;
  final List<CartItem> cartItems;

  OrderModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    this.note,
    required this.status,
    required this.paymentMethod,
    required this.totalMoney,
    required this.feeShipping,
    required this.province,
    required this.district,
    required this.ward,
    required this.detailAddress,
    required this.expectedShippingDate,
    required this.actualShippingDate,
    required this.orderCreatedDate,
    required this.cartItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var cartItemsFromJson = json['cartItems'] as List;
    List<CartItem> cartItemsList =
        cartItemsFromJson.map((i) => CartItem.fromJson(i)).toList();

    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      note: json['note'] ?? " ",
      status: json['status'],
      paymentMethod: json['payment_method'],
      totalMoney: json['total_money'],
      feeShipping: json['fee_shipping'],
      province: json['province'],
      district: json['district'],
      ward: json['ward'],
      detailAddress: json['detail_address'],
      expectedShippingDate: DateTime.parse(json['expected_shipping_date']),
      actualShippingDate: DateTime.parse(json['actual_shipping_date']),
      orderCreatedDate: DateTime.parse(json['order_created_date']),
      cartItems: cartItemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'note': note ?? " ",
      'status': status,
      'payment_method': paymentMethod,
      'total_money': totalMoney,
      'fee_shipping': feeShipping,
      'province': province,
      'district': district,
      'ward': ward,
      'detail_address': detailAddress,
      'expected_shipping_date': expectedShippingDate.toIso8601String(),
      'actual_shipping_date': actualShippingDate.toIso8601String(),
      'order_created_date': orderCreatedDate.toIso8601String(),
      'cartItems': cartItems.map((e) => e.toJson()).toList(),
    };
  }
}
