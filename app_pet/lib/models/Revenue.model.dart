class Revenue {
  final String month;
  final int totalRevenue;

  Revenue({required this.month, required this.totalRevenue});

  factory Revenue.fromJson(Map<String, dynamic> json) {
    return Revenue(
      month: json['month'],
      totalRevenue: json['totalRevenue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'totalRevenue': totalRevenue,
    };
  }
}
