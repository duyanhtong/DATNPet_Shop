// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/screens/addresses/components/address.component.dart';
import 'package:shop_app/screens/sign_in/sign_in_screen.dart';
import 'package:shop_app/services/api.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';


class CompleteProfileForm extends StatefulWidget {
  const CompleteProfileForm({super.key});

  @override
  _CompleteProfileFormState createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  String? fullName;
  String? phoneNumber;
  String? detailAddress;
  String? ward;
  String? district;
  String? province;

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  void updateAddressSelection(Map<String, String> addressData) {
    setState(() {
      province = addressData['province'];
      district = addressData['district'];
      ward = addressData['ward'];
    });
  }

  void printCollectedData() {
    print('Full Name: $fullName');
    print('Phone Number: $phoneNumber');
    print('Province: $province');
    print('District: $district');
    print('Ward: $ward');
    print('Detail Address: $detailAddress');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
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
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
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
              suffixIcon:
                  CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
            ),
          ),
          FormError(errors: errors),
          const SizedBox(height: 20),
          ElevatedButton(
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
               
                if (message == "Cập nhật thông tin thành công") {
                  Navigator.pushNamed(context, SignInScreen.routeName);
                } else {
                  
                  showCustomDialog(context, "Đăng kí", message);
                }
              }
            },
            child: const Text("Tiếp tục"),
          ),
        ],
      ),
    );
  }
}
