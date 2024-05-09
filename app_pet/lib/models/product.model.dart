import 'package:shop_app/models/product_variant.model.dart';

class ProductModel {
  final int id;
  final String name;
  final String? description;
  final String? ingredient;
  final String? origin;
  final String? brand;
  final String? unit;
  final int isBestSeller;
  final double rating;
  final int sold;
  final int category_id;
  final String imagePath;
  final List<ProductVariantModel> productVariant;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.ingredient,
    this.origin,
    this.brand,
    this.unit,
    required this.isBestSeller,
    required this.rating,
    required this.sold,
    required this.category_id,
    required this.imagePath,
    required this.productVariant,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? ' ',
      ingredient: json['ingredient'] ?? ' ',
      origin: json['origin'] ?? ' ',
      brand: json['brand'] ?? ' ',
      unit: json['unit'] ?? ' ',
      isBestSeller: json['is_best_seller'],
      rating: (json['rating'] ?? 0).toDouble(),
      sold: json['sold'],
      category_id: json['category_id'],
      imagePath: json['image_path'],
      productVariant: (json['product_variant'] as List)
          .map((i) => ProductVariantModel.fromJson(i))
          .toList(),
    );
  }
}
