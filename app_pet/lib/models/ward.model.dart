class Ward {
  final String code;
  final String name;
  final String nameEn;
  final String fullName;

  Ward({
    required this.code,
    required this.name,
    required this.nameEn,
    required this.fullName,
  });

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      code: json['code'],
      name: json['name'],
      nameEn: json['nameEn'],
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nameEn': nameEn,
      'fullName': fullName,
    };
  }
}
