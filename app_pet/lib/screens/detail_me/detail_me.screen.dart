// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/user.model.dart';
import 'package:shop_app/screens/addresses/components/address.component.dart';
import 'package:shop_app/screens/profile/components/profile_pic.dart';
import 'package:shop_app/services/api.dart';

class DetailMeScreen extends StatefulWidget {
  const DetailMeScreen({Key? key}) : super(key: key);

  @override
  _DetailMeScreenState createState() => _DetailMeScreenState();
}

class _DetailMeScreenState extends State<DetailMeScreen> {
  late Future<UserModel?> _futureUserProfile;

  Map<String, String> selectedAddress = {
    'province': '',
    'district': '',
    'ward': '',
  };

  @override
  void initState() {
    super.initState();
    _refreshMe();
  }

  void _refreshMe() {
    setState(() {
      _futureUserProfile = Api.getProfile();
    });
  }

  void _showEditDialog({
    required String title,
    required String currentValue,
    required TextEditingController controller,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sửa $title"),
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Nhập $title mới",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy bỏ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lưu'),
              onPressed: () async {
                
                String? result;
                if (title == 'Địa Chỉ') {
                  result = await Api.updateAddressMe(
                    province: title == 'Địa Chỉ' ? controller.text : null,
                    district: title == 'Địa Chỉ' ? controller.text : null,
                    ward: title == 'Địa Chỉ' ? controller.text : null,
                  );
                  Navigator.of(context).pop();
                  if (result == "OK") {
                    _refreshMe();
                  } else {
                    showCustomDialog(
                        context, "Thông báo", result ?? "Có lỗi xảy ra");
                  }
                } else {
                  result = await Api.updateAddressMe(
                    fullName: title == 'Tên Đầy Đủ' ? controller.text : null,
                    phoneNumber:
                        title == 'Số Điện Thoại' ? controller.text : null,
                    detailAddress:
                        title == 'Địa chỉ chi tiết' ? controller.text : null,
                  );
                }
                Navigator.of(context).pop();
                if (result == "OK") {
                  _refreshMe();
                } else {
                  showCustomDialog(
                      context, "Thông báo", result ?? "Có lỗi xảy ra");
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông Tin Chi Tiết',
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
      ),
      body: FutureBuilder<UserModel?>(
        future: _futureUserProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi.'));
          } else {
            UserModel? user = snapshot.data;
            if (user != null) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Center(child: ProfilePic()),
                      const SizedBox(height: 20),
                      _infoField(
                        title: 'Tên Đầy Đủ',
                        value: user.fullName,
                        context: context,
                        user: user,
                      ),
                      _infoField(
                        title: 'Số Điện Thoại',
                        value: user.phoneNumber,
                        context: context,
                        user: user,
                      ),
                      _infoField(
                        title: 'Địa Chỉ',
                        value:
                            '${user.province}, ${user.district}, ${user.ward}',
                        context: context,
                        user: user,
                      ),
                      _infoField(
                        title: 'Email',
                        value: user.email,
                        context: context,
                        user: user,
                      ),
                      _infoField(
                        title: 'Địa chỉ chi tiết',
                        value: user.detailAddress,
                        context: context,
                        user: user,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(
                  child: Text('Không tìm thấy thông tin người dùng.'));
            }
          }
        },
      ),
    );
  }

  Widget _infoField(
      {required String title,
      required String value,
      required BuildContext context,
      required UserModel user}) {
    TextEditingController controller = TextEditingController(text: value);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value),
              ],
            ),
          ),
          if (title != 'Email')
            IconButton(
              icon: const Icon(Icons.edit, color: kPrimaryColor),
              onPressed: () {
                if (title == 'Địa Chỉ') {
                  _showAddressSelection(
                    context,
                    user.province,
                    user.district,
                    user.ward,
                  );
                } else {
                  _showEditDialog(
                    title: title,
                    currentValue: value,
                    controller: controller,
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  void _showAddressSelection(BuildContext context, String initialProvince,
      String initialDistrict, String initialWard) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Chỉnh Sửa Địa Chỉ'),
              content: AddressSelectionWidget(
                initialDistrict: initialDistrict,
                initialProvince: initialProvince,
                initialWard: initialWard,
                onSelectionChanged: (addressData) {
                  // Xử lý khi địa chỉ được thay đổi
                  print('Địa chỉ mới: $addressData');
                  setState(() {
                    // Cập nhật giá trị địa chỉ mới vào state
                    selectedAddress = addressData;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Hủy bỏ'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Lưu'),
                  onPressed: () async {
                    // Gửi cập nhật địa chỉ mới lên server
                    String result = await Api.updateAddressMe(
                      province: selectedAddress['province'],
                      district: selectedAddress['district'],
                      ward: selectedAddress['ward'],
                    );
                    Navigator.of(context).pop();
                    if (result == "OK") {
                      _refreshMe();
                    } else {
                      showCustomDialog(
                          context, "Thông báo", result ?? "Có lỗi xảy ra");
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
