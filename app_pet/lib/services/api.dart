import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/CartItem.model.dart';
import 'package:shop_app/models/product.model.dart';

class Api {
  static const baseUrl = "http://192.168.1.153:4000/";
  static String? accessToken;
  static String? refreshToken;

  static Future<Map<String, dynamic>> login(Map data) async {
    var url = Uri.parse("${baseUrl}auth/login");
    try {
      final res = await http.post(url, body: data);
      var responseData = jsonDecode((res.body.toString()));
      if (responseData["success"] == 1) {
        var responseData = jsonDecode((res.body.toString()));
        print(responseData);
        accessToken = responseData['data']['accessToken'];
        refreshToken = responseData['data']['refreshToken'];
        return {"boolean": true};
      } else {
        var responseData = jsonDecode((res.body.toString()));
        return {"boolean": false, "message": responseData["data"]['message']};
      }
    } catch (error) {
      debugPrint(error.toString());
      return {
        "success": false,
        "message": "Đã có lỗi xảy ra. Vui lòng thử lại sau."
      };
    }
  }

  static Future<Map<String, dynamic>> getAllCategory() async {
    var url = Uri.parse("${baseUrl}category");
    try {
      final res = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      var responseData = jsonDecode((res.body.toString()));
      if (responseData["success"] == 1) {
        print(responseData);
        final Map<String, dynamic> data = json.decode(res.body);
        return {
          "success": true,
          "data": data["data"],
        };
      } else {
        return {
          "success": false,
          "message": responseData["data"]['message'],
        };
      }
    } catch (error) {
      debugPrint(error.toString());
      return {
        "success": false,
        "message": "Đã có lỗi xảy ra. Vui lòng thử lại sau.",
      };
    }
  }

  static Future<List<ProductModel>> getAllProduct({String? searchQuery}) async {
    var url = Uri.parse(
        "${baseUrl}product${searchQuery != null ? '?search=$searchQuery' : ''}");
    try {
      final res = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print(url);
      var responseData = json.decode(res.body.toString());
      if (responseData["success"] == 1) {
        List<dynamic> productData = responseData["data"]['products'];
        print(productData);
        List<ProductModel> products = productData
            .map((dynamic item) => ProductModel.fromJson(item))
            .toList();
        return products;
      } else {
        return [];
      }
    } catch (error) {
      print(error.toString());

      return [];
    }
  }

  static Future<List<CartItem>> getListCartItem() async {
    var url = Uri.parse("${baseUrl}cart-item");
    try {
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      var responseData = jsonDecode((res.body.toString()));
      if (responseData["success"] == 1) {
        List<dynamic> cartItemData = responseData["data"]['cartItems'];
        print('---------------------------');
        print(cartItemData);
        List<CartItem> cartItems = cartItemData
            .map((dynamic item) => CartItem.fromJson(item))
            .toList();
        return cartItems;
      } else {
        return [];
      }
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  static Future<String> addProductToCart(
      int productVariantId, int quantity) async {
    var url = Uri.parse("${baseUrl}cart-item");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "product_variant_id": productVariantId,
          "quantity": quantity,
        }),
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        // Nếu API trả về thành công
        return "Thêm vào giỏ hàng thành công";
      } else {
        // Lấy thông điệp lỗi từ phản hồi của API
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<void> updateCart(int cartId, int quantity) async {
    var url = Uri.parse("${baseUrl}cart-item/$cartId");
    try {
      print("api update cart-------------------");
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "quantity": quantity,
        }),
      );
      var responseData = jsonDecode(response.body);
      if (responseData["success"] != 1) {
        return Future.error(responseData['data']['message'] ?? "Có lỗi xảy ra");
      }
    } catch (error) {
      debugPrint(error.toString());
      return Future.error("Có lỗi xảy ra trong quá trình thực hiện");
    }
  }
}
