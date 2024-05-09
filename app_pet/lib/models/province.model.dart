class Province {
  final String code;
  final String name;
  final String nameEn;
  final String fullName;

  Province({
    required this.code,
    required this.name,
    required this.nameEn,
    required this.fullName,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
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
