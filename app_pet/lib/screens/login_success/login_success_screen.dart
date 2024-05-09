import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/user.model.dart';
import 'package:shop_app/screens/admin-dashboard/dashboard_screen.dart';
import 'package:shop_app/screens/init_screen.dart';
import 'package:shop_app/services/api.dart'; // Giả sử đây là file chứa UserModel

class LoginSuccessScreen extends StatelessWidget {
  static String routeName = "/login_success";

  const LoginSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //  leading: const SizedBox(),
        title: const Text(
          "Đăng nhập thành công",
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/sign_in');
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Image.asset(
            "assets/images/success.png",
            height: MediaQuery.of(context).size.height * 0.4, //40%
          ),
          const SizedBox(height: 16),
          const Text(
            "Đăng nhập thành công",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  UserModel user = await Api.getProfile();
                  print("user nè--------------");
                  print(user.role);
                  if (user.role == "user") {
                    Navigator.pushNamed(context, InitScreen.routeName);
                  } else if (user.role == "admin") {
                    Navigator.pushNamed(context, DashboardScreen.routeName);
                  } else {
                    // Xử lý trường hợp role không hợp lệ hoặc không xác định
                    print("Role không hợp lệ");
                  }
                } catch (error) {
                  // Xử lý lỗi
                  print("Có lỗi xảy ra: $error");
                }
              },
              child: const Text("Trở lại trang chủ"),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
