import 'package:flutter/material.dart';
import 'package:shop_app/components/custom_surfix_icon.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/screens/addresses/components/address.component.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/services/api.dart';

class AddAddressDialog extends StatelessWidget {
  final Function(Map<String, String>) onAddressAdded;

  const AddAddressDialog({Key? key, required this.onAddressAdded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final List<String?> errors = [];
    String? fullName;
    String? phoneNumber;
    String? detailAddress;
    String? ward;
    String? district;
    String? province;

    void addError({String? error}) {
      if (!errors.contains(error)) {
        errors.add(error);
      }
    }

    void removeError({String? error}) {
      if (errors.contains(error)) {
        errors.remove(error);
      }
    }

    void printCollectedData() {
      print('Full Name: $fullName');
      print('Phone Number: $phoneNumber');
      print('Province: $province');
      print('District: $district');
      print('Ward: $ward');
      print('Detail Address: $detailAddress');
    }

    void updateAddressSelection(Map<String, String> addressData) {
      province = addressData['province'];
      district = addressData['district'];
      ward = addressData['ward'];
    }

    return AlertDialog(
      title: Text(
        'Thêm địa chỉ mới',
        style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
      ),
      content: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  onSaved: (newValue) => fullName = newValue,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      removeError(error: kNamelNullError);
                    }
                    return;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      addError(error: kNamelNullError);
                      return "";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Họ và tên",
                    hintText: "Nhập họ và tên của bạn",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon:
                        CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  onSaved: (newValue) => phoneNumber = newValue,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      removeError(error: kPhoneNumberNullError);
                    }
                    return;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      addError(error: kPhoneNumberNullError);
                      return "";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Nhập số điện thoại",
                    hintText: "Nhập số điện thoại của bạn",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon:
                        CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
                  ),
                ),
                const SizedBox(height: 20),
                AddressSelectionWidget(
                  onSelectionChanged: updateAddressSelection,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onSaved: (newValue) => detailAddress = newValue,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      removeError(error: kAddressNullError);
                    }
                    return;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      addError(error: kAddressNullError);
                      return "";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Tên đường, Toà nhà, Số nhà",
                    hintText: "Nhập địa chỉ chi tiết",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: CustomSurffixIcon(
                        svgIcon: "assets/icons/Location point.svg"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              printCollectedData();
              String message = await Api.createAddress(
                fullName ?? '',
                phoneNumber ?? '',
                province ?? '',
                district ?? '',
                ward ?? '',
                detailAddress ?? '',
              );
              print(message);

              if (message == "Cập nhật thông tin thành công") {
                onAddressAdded({
                  'province': province!,
                  'district': district!,
                  'ward': ward!,
                });
                Navigator.of(context).pop(); // Đóng dialog
              } else {
                showCustomDialog(context, "Thêm mới địa chỉ", message);
              }
            }
          },
          child: Text('Thêm'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
          },
          child: Text('Hủy'),
        ),
      ],
    );
  }
}
