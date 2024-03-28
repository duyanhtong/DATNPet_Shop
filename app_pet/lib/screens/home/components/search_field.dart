import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:shop_app/screens/products/products_screen.dart';
import '../../../constants.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    return Form(
      child: TextFormField(
        controller: searchController,
        onFieldSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsScreen(searchQuery: value),
              ),
            );

            searchController.clear();
          }
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: kSecondaryColor.withOpacity(0.1),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: searchOutlineInputBorder,
          focusedBorder: searchOutlineInputBorder,
          enabledBorder: searchOutlineInputBorder,
          hintText: "Tìm kiếm sản phẩm",
          prefixIcon: InkWell(
            onTap: () {
              // Thực hiện tìm kiếm khi nhấp vào icon
              if (searchController.text.isNotEmpty) {
                Navigator.pushNamed(context, ProductsScreen.routeName,
                    arguments: searchController.text);
                // Xoá text sau khi thực hiện tìm kiếm
                searchController.clear();
              }
            },
            child: const Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}

const searchOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide.none,
);
