class TopProductSellModel {
  final int productSold;
  final String productName;

  TopProductSellModel({
    required this.productSold,
    required this.productName,
  });

  factory TopProductSellModel.fromJson(Map<String, dynamic> json) {
    return TopProductSellModel(
      productSold: json['product_sold'],
      productName: json['product_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_sold': productSold,
      'product_name': productName,
    };
  }
}
