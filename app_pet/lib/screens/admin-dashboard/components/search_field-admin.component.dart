import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';

class SearchFieldAdmin extends StatelessWidget {
  const SearchFieldAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm...',
          prefixIcon: Icon(Icons.search, color: kPrimaryColor),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        ),
      ),
    );
  }
}
