class CartItem {
  final int id;
  final int productVariantId;
  final String productName;
  final String productVariantName;
  final String image;
  final int price;
  final int promotion;
  final int quantity;

  CartItem({
    required this.id,
    required this.productVariantId,
    required this.productName,
    required this.productVariantName,
    required this.image,
    required this.price,
    required this.promotion,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productVariantId: json['product_variant_id'],
      productName: json['product_name'],
      productVariantName: json['product_variant_name'],
      image: json['image'],
      price: json['price'],
      promotion: json['promotion'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_variant_id': productVariantId,
      'product_name': productName,
      'product_variant_name': productVariantName,
      'image': image,
      'price': price,
      'promotion': promotion,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    int? id,
    int? productVariantId,
    String? productName,
    String? productVariantName,
    String? image,
    int? price,
    int? promotion,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productVariantId: productVariantId ?? this.productVariantId,
      productName: productName ?? this.productName,
      productVariantName: productVariantName ?? this.productVariantName,
      image: image ?? this.image,
      price: price ?? this.price,
      promotion: promotion ?? this.promotion,
      quantity: quantity ?? this.quantity,
    );
  }
}
