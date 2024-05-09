class AddressModel {
  final int id;
  final int userId;
  final String fullname;
  final String province;
  final String district;
  final String ward;
  final String detailAddress;
  final String phoneNumber;
  final bool isActive;

  AddressModel({
    required this.id,
    required this.userId,
    required this.fullname,
    required this.province,
    required this.district,
    required this.ward,
    required this.detailAddress,
    required this.phoneNumber,
    required this.isActive,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      userId: json['user_id'],
      fullname: json['fullname'],
      province: json['province'],
      district: json['district'],
      ward: json['ward'],
      detailAddress: json['detail_address'],
      phoneNumber: json['phone_number'],
      isActive: json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fullname': fullname,
      'province': province,
      'district': district,
      'ward': ward,
      'detail_address': detailAddress,
      'phone_number': phoneNumber,
      'is_active': isActive ? 1 : 0,
    };
  }
}
