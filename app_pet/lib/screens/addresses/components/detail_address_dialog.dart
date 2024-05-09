import 'package:flutter/material.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/components/custom_surfix_icon.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/Address.model.dart';
import 'package:shop_app/screens/addresses/components/address.component.dart';
import 'package:shop_app/services/api.dart';

class AddressDetailsDialog extends StatefulWidget {
  final AddressModel address;

  const AddressDetailsDialog({Key? key, required this.address})
      : super(key: key);

  @override
  State<AddressDetailsDialog> createState() => _AddressDetailsDialogState();
}

class _AddressDetailsDialogState extends State<AddressDetailsDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  String? fullName;
  String? phoneNumber;
  String? detailAddress;
  String? ward;
  String? district;
  String? province;

  @override
  void initState() {
    super.initState();
    fullName = widget.address.fullname;
    phoneNumber = widget.address.phoneNumber;
    detailAddress = widget.address.detailAddress;
    ward = widget.address.ward;
    district = widget.address.district;
    province = widget.address.province;
  }

  @override
  Widget build(BuildContext context) {
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

    void updateAddressSelection(Map<String, String> addressData) {
      province = addressData['province'];
      district = addressData['district'];
      ward = addressData['ward'];
    }

    void printCollectedData() {
      print('Full Name: $fullName');
      print('Phone Number: $phoneNumber');
      print('Province: $province');
      print('District: $district');
      print('Ward: $ward');
      print('Detail Address: $detailAddress');
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
                  initialValue: fullName,
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
                  initialValue: phoneNumber,
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
                  initialDistrict: district,
                  initialProvince: province,
                  initialWard: ward,
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
                  initialValue: detailAddress,
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
              String message = await Api.updateAddress(
                widget.address.id,
                fullName ?? '',
                phoneNumber ?? '',
                province ?? '',
                district ?? '',
                ward ?? '',
                detailAddress ?? '',
              );
              print(message);

              if (message == "OK") {
                Navigator.of(context).pop(); // Đóng dialog
              } else {
                showCustomDialog(context, "Chi tiết địa chỉ", message);
              }
            }
          },
          child: Text('Cập nhật'),
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
