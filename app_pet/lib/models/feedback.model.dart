class FeedbackModel {
  final int id;
  final int userId;
  final int productVariantId;
  final int orderId;
  final String status;
  final double? rating;
  final String? comment;
  final String? image;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.productVariantId,
    required this.orderId,
    required this.status,
    this.rating,
    this.comment,
    this.image,
  });

  // Factory constructor for creating a new FeedbackModel instance from a map (useful for JSON deserialization)
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      userId: json['user_id'],
      productVariantId: json['product_variant_id'],
      orderId: json['order_id'],
      status: json['status'],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      comment: json['comment'],
      image: json['image'],
    );
  }

  // Method for converting a FeedbackModel instance to a map (useful for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_variant_id': productVariantId,
      'order_id': orderId,
      'status': status,
      'rating': rating,
      'comment': comment,
      'image': image,
    };
  }
}
