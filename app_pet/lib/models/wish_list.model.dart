import 'package:shop_app/models/product.model.dart';

class WishListModel {
  final int id;
  final ProductModel product;
  final int total;

  WishListModel({
    required this.id,
    required this.product,
    required this.total,
  });

  factory WishListModel.fromJson(Map<String, dynamic> json) {
    return WishListModel(
      id: json['id'],
      product: ProductModel.fromJson(json['product']),
      total: json['total'] ?? 0,
    );
  }
}
