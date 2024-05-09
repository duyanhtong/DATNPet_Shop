class UserModel {
  final int id;
  final String email;
  final String image;
  final String role;
  final int addressId;
  final String province;
  final String district;
  final String ward;
  final String detailAddress;
  final String phoneNumber;
  final String fullName;

  UserModel({
    required this.id,
    required this.email,
    required this.image,
    required this.role,
    required this.addressId,
    required this.province,
    required this.district,
    required this.ward,
    required this.detailAddress,
    required this.phoneNumber,
    required this.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      image: json['image'],
      role: json['role'],
      addressId: json['address_id'],
      province: json['province'],
      district: json['district'],
      ward: json['ward'],
      detailAddress: json['detail_address'],
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'image': image,
      'role': role,
      'address_id': addressId,
      'province': province,
      'district': district,
      'ward': ward,
      'detail_address': detailAddress,
      'phone_number': phoneNumber,
      'full_name': fullName,
    };
  }
}
