import 'package:flutter/material.dart';

import '../../constants.dart';
import 'components/complete_profile_form.dart';

class CompleteProfileScreen extends StatelessWidget {
  static String routeName = "/complete_profile";

  const CompleteProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đăng ký',
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 1),
                  const Text("Thông tin cá nhân", style: headingStyle),
                  const Text(
                    "Hoàn thành thông tin cá nhân của bạn",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const CompleteProfileForm(),
                  const SizedBox(height: 30),
                  Text(
                    "Bằng cách tiếp tục, bạn xác nhận đồng ý với \nĐiều khoản và Điều kiện của chúng tôi.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
