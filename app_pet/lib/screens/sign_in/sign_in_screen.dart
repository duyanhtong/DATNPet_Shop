import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/helper/keyboard.dart';
import 'package:shop_app/screens/init_screen.dart';
import 'package:shop_app/screens/login_success/login_success_screen.dart';

import '../../components/no_account_text.dart';
import '../../components/socal_card.dart';
import 'components/sign_form.dart';

class SignInScreen extends StatelessWidget {
  static String routeName = "/sign_in";

  const SignInScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Đăng nhập",
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
                  const SizedBox(height: 16),
                  const Text(
                    "Chào Mừng Bạn Đã Trở Lại",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Đăng nhập bằng email và mật khẩu của bạn",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const SignForm(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocalCard(
                        icon: "assets/icons/google-icon.svg",
                        press: () {},
                      ),
                      SocalCard(
                        icon: "assets/icons/facebook-2.svg",
                        press: () {},
                      ),
                      SocalCard(
                        icon: "assets/icons/twitter.svg",
                        press: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const NoAccountText(),
                  const SizedBox(height: 1),
                  TextButton(
                    onPressed: () {
                      KeyboardUtil.hideKeyboard(context);
                      Navigator.pushNamed(context, InitScreen.routeName);
                    },
                    child: const Text(
                      "Tiếp tục đến trang chủ",
                      style: TextStyle(color: kPrimaryColor),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
