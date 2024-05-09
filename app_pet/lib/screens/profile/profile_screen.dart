import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/screens/addresses/list-address.screen.dart';
import 'package:shop_app/screens/detail_me/detail_me.screen.dart';
import 'package:shop_app/screens/order/order.screen.dart';
import 'package:shop_app/services/api.dart';

import 'components/profile_menu.dart';
import 'components/profile_pic.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thông tin cá nhân",
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic(),
            const SizedBox(height: 20),
            ProfileMenu(
              text: "Tài khoản của bạn",
              icon: "assets/icons/User Icon.svg",
              press: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DetailMeScreen()),
                )
              },
            ),
            ProfileMenu(
              text: "Thông báo",
              icon: "assets/icons/Bell.svg",
              press: () {},
            ),
            ProfileMenu(
              text: "Đơn hàng",
              icon: "assets/icons/Cart Icon.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersScreen()),
                );
              },
            ),
            ProfileMenu(
              text: "Địa chỉ",
              icon: "assets/icons/Location point.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ListAddressScreen()),
                );
              },
            ),
            ProfileMenu(
              text: "Đăng xuất",
              icon: "assets/icons/Log out.svg",
              press: () {
                Api.accessToken = null;
                Api.refreshToken = null;
                Navigator.pushNamedAndRemoveUntil(
                    context, '/splash', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
