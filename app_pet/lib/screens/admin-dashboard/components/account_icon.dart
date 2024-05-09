import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';

class AccountIcon extends StatelessWidget {
  const AccountIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.account_circle, color: kPrimaryColor),
      onPressed: () {
        // Logic to show user profile or login screen
      },
    );
  }
}
