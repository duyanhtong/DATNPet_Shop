class ProductVariantModel {
  final int id;
  final String name;
  final String productCode;
  final int productId;
  final int price;
  final int discountRate;
  final int inventory;
  final String imagePath;

  ProductVariantModel({
    required this.id,
    required this.name,
    required this.productCode,
    required this.productId,
    required this.price,
    required this.discountRate,
    required this.inventory,
    required this.imagePath,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'],
      name: json['name'],
      productCode: json['product_code'],
      productId: json['product_id'],
      price: json['price'],
      discountRate: json['discount_rate'],
      inventory: json['inventory'],
      imagePath: json['image_path'],
    );
  }
}
