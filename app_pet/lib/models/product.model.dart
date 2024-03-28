import 'package:shop_app/models/product_variant.model.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final int isBestSeller;
  final double rating;
  final int sold;
  final String imagePath;
  final List<ProductVariantModel> productVariant;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isBestSeller,
    required this.rating,
    required this.sold,
    required this.imagePath,
    required this.productVariant,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isBestSeller: json['is_best_seller'],
      rating: json['rating'].toDouble(),
      sold: json['sold'],
      imagePath: json['image_path'],
      productVariant: (json['product_variant'] as List)
          .map((i) => ProductVariantModel.fromJson(i))
          .toList(),
    );
  }
}
