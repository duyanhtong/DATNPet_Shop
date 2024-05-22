import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shop_app/models/Address.model.dart';
import 'package:shop_app/models/CartItem.model.dart';
import 'package:shop_app/models/Revenue.model.dart';
import 'package:shop_app/models/TopProductSell.model.dart';
import 'package:shop_app/models/district.model.dart';
import 'package:shop_app/models/feedback.model.dart';
import 'package:shop_app/models/order.model.dart';
import 'package:shop_app/models/product.model.dart';
import 'package:shop_app/models/province.model.dart';
import 'package:shop_app/models/user.model.dart';
import 'package:shop_app/models/ward.model.dart';
import 'package:shop_app/models/wish_list.model.dart';

class Api {
  //static const baseUrl = "http://192.168.1.153:4000/";
  //static const baseUrl = "http://192.168.0.101:4000/";
  static const baseUrl = "http://192.168.88.232:4000/";
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

  static Future<String> register(
      String email, String password, String rePassword) async {
    var url = Uri.parse("${baseUrl}auth/register");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {"email": email, "password": password, "rePassword": rePassword}),
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        await login({"email": email, "password": password});
        return "Đăng kí thành công";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<Map<String, dynamic>> getAllCategory() async {
    var url = Uri.parse("${baseUrl}category");
    print("run api get all category : $url");
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

  static Future<String> updateCategory(int categoryId, String name) async {
    var url = Uri.parse("${baseUrl}category/$categoryId");
    try {
      print("run api udpate category $url");
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({"name": name}),
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return "OK";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> removeCategory(int categoryId) async {
    var url = Uri.parse("${baseUrl}category/$categoryId");
    try {
      print("run api udpate category $url");
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return "OK";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> createCategory(String name) async {
    var url = Uri.parse("${baseUrl}category");
    try {
      print("run api udpate category $url");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({"name": name}),
      );
      var responseData = jsonDecode(response.body.toString());

      if (responseData["success"] == 1) {
        return "OK";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<List<ProductModel>> getAllProduct(
      {String? searchQuery,
      int? categoryId,
      int? page,
      int? is_best_seller}) async {
    final queryParams = <String, String>{};

    if (searchQuery != null) {
      queryParams['search'] = searchQuery;
    }

    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }

    if (page != null) {
      queryParams['page'] = page.toString();
    }
    if (is_best_seller != null) {
      queryParams['is_best_seller'] = is_best_seller.toString();
    }

    final uri = Uri.parse(
        '${baseUrl}product${queryParams.isNotEmpty ? '?' : ''}${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');
    print("API get all product: $uri");

    try {
      final response =
          await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == 1) {
          final productData = responseData['data']['products'] as List<dynamic>;
          return productData
              .map((dynamic item) => ProductModel.fromJson(item))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
            'Failed to fetch products: Status code ${response.statusCode}');
      }
    } catch (error) {
      print(error.toString());
      return [];
    }
  }

  static Future<ProductModel> getProductByProductVariantId(
      int productId) async {
    var url = Uri.parse("${baseUrl}product-variant/product/${productId}");
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return ProductModel.fromJson(responseData['data']);
      } else {
        throw Exception(responseData["message"] ?? "Có lỗi xảy ra");
      }
    } catch (error) {
      print(error.toString());
      throw Exception("Có lỗi xảy ra trong quá trình thực hiện: $error");
    }
  }

  static Future<ProductModel> getDetailProduct(int productId) async {
    var url = Uri.parse("${baseUrl}product/${productId}");
    print("run api get detail prouduct: $url");
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return ProductModel.fromJson(responseData['data']);
      } else {
        throw Exception(responseData["message"] ?? "Có lỗi xảy ra");
      }
    } catch (error) {
      print(error.toString());
      throw Exception("Có lỗi xảy ra trong quá trình thực hiện: $error");
    }
  }

  static Future<int> getCountProduct(String searchQuery) async {
    var queryParams = '?search=$searchQuery';

    var url = Uri.parse("${baseUrl}product/count$queryParams");

    try {
      final res =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      var responseData = json.decode(res.body.toString());
      if (responseData["success"] == 1) {
        int productCount = responseData["data"]['total'];

        return productCount;
      } else {
        return 0;
      }
    } catch (error) {
      print(error.toString());
      return 0;
    }
  }

  static Future<String> updateProduct(
      {required int productId,
      File? productImage,
      String? productName,
      String? description,
      String? ingredient,
      String? origin,
      String? brand,
      String? unit,
      int? is_best_seller,
      required int category_id}) async {
    var url = Uri.parse("${baseUrl}product/${productId}");

    try {
      var request = http.MultipartRequest('PUT', url)
        ..fields['name'] = productName ?? ''
        ..fields['description'] = description ?? ''
        ..fields['ingredient'] = ingredient ?? ''
        ..fields['origin'] = origin ?? ''
        ..fields['brand'] = brand ?? ''
        ..fields['unit'] = unit ?? ''
        ..fields['is_best_seller'] = is_best_seller.toString()
        ..fields['category_id'] = category_id.toString();

      // Thêm file vào request nếu có
      if (productImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'productImage',
          productImage.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var decodedResponse = json.decode(responseString);

        if (decodedResponse["success"] == 1) {
          return "OK";
        } else {
          return decodedResponse["data"]['message'];
        }
      } else {
        return "Có lỗi xảy ra trong quá trình thực hiện";
      }
    } catch (error) {
      print(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> createProduct(
      {required File productImage,
      required String productName,
      String? description,
      String? ingredient,
      String? origin,
      String? brand,
      String? unit,
      required int category_id}) async {
    var url = Uri.parse("${baseUrl}product");
    print("api create product: $url");
    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['name'] = productName ?? ''
        ..fields['description'] = description ?? ''
        ..fields['ingredient'] = ingredient ?? ''
        ..fields['origin'] = origin ?? ''
        ..fields['brand'] = brand ?? ''
        ..fields['unit'] = unit ?? ''
        ..fields['category_id'] = category_id.toString();

      // Thêm file vào request nếu có
      if (productImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'productImage',
          productImage.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
      });

      var response = await request.send();
      if (response.statusCode == 201) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var decodedResponse = json.decode(responseString);

        if (decodedResponse["success"] == 1) {
          return "OK";
        } else {
          return decodedResponse["data"]['message'];
        }
      } else {
        return "Có lỗi xảy ra trong quá trình thực hiện";
      }
    } catch (error) {
      print(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> removeProduct(int productId) async {
    var url = Uri.parse("${baseUrl}product/$productId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return "OK";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> removeProductVariant(int productVariantId) async {
    var url = Uri.parse("${baseUrl}product-variant/$productVariantId");
    print("run api delete product variant $url");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return "OK";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> updateProductVariant({
    required int productVariantId,
    File? productVariantImage,
    String? product_code,
    String? name,
    int? price,
    int? weight,
    int? discount_rate,
    int? inventory,
  }) async {
    var url = Uri.parse("${baseUrl}product-variant/${productVariantId}");
    print("run api update product variant : $url");
    try {
      var request = http.MultipartRequest('PUT', url)
        ..fields['product_code'] = product_code ?? ''
        ..fields['name'] = name ?? ''
        ..fields['price'] = price.toString()
        ..fields['weight'] = weight.toString()
        ..fields['discount_rate'] = discount_rate.toString()
        ..fields['inventory'] = inventory.toString();
      // Thêm file vào request nếu có
      if (productVariantImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'productVariantImage',
          productVariantImage.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }
      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var decodedResponse = json.decode(responseString);

        if (decodedResponse["success"] == 1) {
          return "OK";
        } else {
          return decodedResponse["data"]['message'];
        }
      } else {
        return "Có lỗi xảy ra trong quá trình thực hiện";
      }
    } catch (error) {
      print(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> createProductVariant({
    required int productId,
    File? productVariantImage,
    String? product_code,
    String? name,
    int? price,
    int? weight,
    int? discount_rate,
    int? inventory,
  }) async {
    var url = Uri.parse("${baseUrl}product-variant");
    print("run api create product variant : $url");
    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['product_code'] = product_code ?? ''
        ..fields['name'] = name ?? ''
        ..fields['price'] = price.toString()
        ..fields['product_id'] = productId.toString()
        ..fields['weight'] = weight.toString()
        ..fields['discount_rate'] = discount_rate.toString()
        ..fields['inventory'] = inventory.toString();
      // Thêm file vào request nếu có
      if (productVariantImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'productVariantImage',
          productVariantImage.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }
      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
      });

      var response = await request.send();

      if (response.statusCode == 201) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var decodedResponse = json.decode(responseString);
        print("----------------------------");
        print(decodedResponse);
        print("----------------------------");
        if (decodedResponse["success"] == 1) {
          return "OK";
        } else {
          return decodedResponse["data"]['message'];
        }
      } else {
        return "Có lỗi xảy ra trong quá trình thực hiện";
      }
    } catch (error) {
      print(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<List<CartItem>> getListCartItem({int? page}) async {
    final queryParams = <String, String>{};
    if (page != null) {
      queryParams['page'] = page.toString();
    }
    var url =
        Uri.parse("${baseUrl}cart-item").replace(queryParameters: queryParams);
    print("run api get all cart item $url");
    try {
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (res.statusCode == 200) {
        var responseData = jsonDecode(res.body);
        if (responseData["success"] == 1) {
          List<dynamic> cartItemData = responseData["data"]['cartItems'];
          List<CartItem> cartItems = cartItemData
              .map((dynamic item) => CartItem.fromJson(item))
              .toList();
          return cartItems;
        } else {
          // If the API response indicates failure, return an empty list
          return [];
        }
      } else {
        // If the API request failed (status code other than 200), throw an exception
        throw Exception('Failed to load cart items: ${res.statusCode}');
      }
    } catch (error) {
      // If an error occurred during the HTTP request or JSON parsing, return an empty list
      debugPrint('Error fetching cart items: $error');
      return [];
    }
  }

  static Future<int> countCartItem() async {
    var url = Uri.parse("${baseUrl}cart-item/count");
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
        return responseData["data"];
      } else {
        return 0;
      }
    } catch (error) {
      debugPrint(error.toString());
      return 0;
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
        print("dskcfdksj");
        print(responseData["data"]);
        return "Thêm vào giỏ hàng thành công";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> updateCart(int cartId, int quantity) async {
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
        return responseData['data']['message'] ?? "Có lỗi xảy ra";
      } else {
        return "OK";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> addProductToWishList(int productId) async {
    var url = Uri.parse("${baseUrl}wish-list");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "product_id": productId,
        }),
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return responseData["data"]["message"];
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<bool> checkProductToWishList(int productId) async {
    var url = Uri.parse("${baseUrl}wish-list/check");
    print("run api check wishlist $url");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "product_id": productId,
        }),
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["data"] != null) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      debugPrint(error.toString());

      return false;
    }
  }

  static Future<List<WishListModel>> getAllWishList() async {
    var url = Uri.parse("${baseUrl}wish-list");
    try {
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      var responseData = json.decode(res.body.toString());

      if (responseData["success"] == 1) {
        List<dynamic> wishListData = responseData["data"]['wishLists'];
        List<WishListModel> wishLists = wishListData
            .map((dynamic item) => WishListModel.fromJson(item))
            .toList();

        return wishLists;
      } else {
        return [];
      }
    } catch (error) {
      print(error.toString());
      return [];
    }
  }

  static Future<List<District>> getListDistrict(String provinceCode) async {
    var url = Uri.parse("${baseUrl}address/district/$provinceCode");
    try {
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      var responseData = jsonDecode((res.body.toString()));
      if (responseData["success"] == 1) {
        List<dynamic> districtData = responseData["data"];
        List<District> districts = districtData
            .map((dynamic item) => District.fromJson(item))
            .toList();
        return districts;
      } else {
        return [];
      }
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  static Future<List<Province>> getListProvince() async {
    var url = Uri.parse("${baseUrl}address/province");
    try {
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      var responseData = jsonDecode((res.body.toString()));
      if (responseData["success"] == 1) {
        List<dynamic> provinceData = responseData["data"];
        List<Province> provinces = provinceData
            .map((dynamic item) => Province.fromJson(item))
            .toList();
        return provinces;
      } else {
        return [];
      }
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  static Future<List<Ward>> getListWard(String districtCode) async {
    var url = Uri.parse("${baseUrl}address/ward/$districtCode");
    try {
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      var responseData = jsonDecode((res.body.toString()));
      if (responseData["success"] == 1) {
        List<dynamic> wardData = responseData["data"];
        List<Ward> wards =
            wardData.map((dynamic item) => Ward.fromJson(item)).toList();
        return wards;
      } else {
        return [];
      }
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  static Future<String> createAddress(
      String fullname,
      String phone_number,
      String province,
      String district,
      String ward,
      String detail_address) async {
    var url = Uri.parse("${baseUrl}address");
    try {
      print("====================");
      print('Full Name: $fullname');
      print('Phone Number: $phone_number');
      print('Province: $province');
      print('District: $district');
      print('Ward: $ward');
      print('Detail Address: $detail_address');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode({
          "fullname": fullname,
          "ward": ward,
          "district": district,
          "province": province,
          "detail_address": detail_address,
          "phone_number": phone_number
        }),
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return "Cập nhật thông tin thành công";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> removeCart(int cartId) async {
    var url = Uri.parse("${baseUrl}cart-item/$cartId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return "OK";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<UserModel> getProfile() async {
    var url = Uri.parse("${baseUrl}auth/profile");
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return UserModel.fromJson(responseData['data']);
      } else {
        throw Exception(responseData["message"] ?? "Có lỗi xảy ra");
      }
    } catch (error) {
      print(error.toString());
      throw Exception("Có lỗi xảy ra trong quá trình thực hiện: $error");
    }
  }

  static Future<String> uploadImage(int userId, File file) async {
    var url = Uri.parse("${baseUrl}user/upload/$userId");
    print("run api update image user $url");
    try {
      var request = http.MultipartRequest('PUT', url)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..files.add(http.MultipartFile(
          'userImage',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var responseData = jsonDecode(response.body.toString());

      if (responseData["success"] == 1) {
        return "OK";
      } else {
        return responseData["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      print(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện: $error";
    }
  }

  static Future<List<AddressModel>> getListAddress(
      {int? page, int? items_per_page}) async {
    var queryParams = '';
    if (page != null) {
      queryParams += '?page=$page';
      if (items_per_page != null) {
        queryParams += '&items_per_page=$items_per_page';
      }
    } else {
      queryParams += '?items_per_page=$items_per_page';
    }
    var url = Uri.parse("${baseUrl}address$queryParams");
    print("Api get list address : $url");
    try {
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      var responseData = json.decode(res.body);

      if (responseData["success"] == 1) {
        List<dynamic> addressData = responseData["data"]['addresses'];
        List<AddressModel> addresses = addressData
            .map((dynamic item) => AddressModel.fromJson(item))
            .toList();
        return addresses;
      } else {
        return [];
      }
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  static Future<String> updateDefaultAddress(int addressId) async {
    var url = Uri.parse("${baseUrl}address/$addressId");
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "is_active": 1,
        }),
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return "Đặt địa chỉ làm mặc định thành công.";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> removeAddress(int addressId) async {
    var url = Uri.parse("${baseUrl}address/$addressId");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken'
        },
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return "OK";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> updateAddress(
      int addressId,
      String fullName,
      String phoneNumber,
      String province,
      String district,
      String ward,
      String detailAddress) async {
    var url = Uri.parse("${baseUrl}address/$addressId");
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "fullname": fullName,
          "ward": ward,
          "district": district,
          "province": province,
          "detail_address": detailAddress,
          "phone_number": phoneNumber
        }),
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return "OK";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<String> updateAddressMe({
    String? fullName,
    String? phoneNumber,
    String? province,
    String? district,
    String? ward,
    String? detailAddress,
  }) async {
    var url = Uri.parse("${baseUrl}address/update/me");
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          if (fullName != null) "fullname": fullName,
          if (phoneNumber != null) "phone_number": phoneNumber,
          if (province != null) "province": province,
          if (district != null) "district": district,
          if (ward != null) "ward": ward,
          if (detailAddress != null) "detail_address": detailAddress,
        }),
      );
      var responseData = jsonDecode(response.body.toString());
      if (responseData["success"] == 1) {
        return "OK";
      } else {
        return responseData["data"]["message"] ?? "Có lỗi xảy ra";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<AddressModel?> getDefaultAddress() async {
    var url = Uri.parse("${baseUrl}address/default/me");
    try {
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      var responseData = json.decode(res.body);

      if (responseData["success"] == 1 && responseData["data"] != null) {
        AddressModel address = AddressModel.fromJson(responseData["data"]);
        return address;
      } else {
        return null;
      }
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  static Future<AddressModel?> getAddressById(int addressId) async {
    var url = Uri.parse("${baseUrl}address/${addressId}");
    try {
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      var responseData = json.decode(res.body);

      if (responseData["success"] == 1 && responseData["data"] != null) {
        AddressModel address = AddressModel.fromJson(responseData["data"]);
        return address;
      } else {
        return null;
      }
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  static Future<int?> calculateFeeShipping({
    required int addressId,
    required List<int> cartIds,
  }) async {
    var url = Uri.parse("${baseUrl}order/fee-shipping");
    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "addressId": addressId,
          "cartIds": cartIds,
        }),
      );

      var responseData = json.decode(res.body);
      if (responseData["success"] == 1 && responseData["data"] != null) {
        return responseData["data"] is int
            ? responseData["data"]
            : int.tryParse(responseData["data"].toString());
      } else {
        return null;
      }
    } catch (error) {
      debugPrint("Error calculating fee shipping: ${error.toString()}");
      return null;
    }
  }

  static Future<String> createOrder(
      {required int address_id,
      required List<int> carts,
      required String payment_method}) async {
    var url = Uri.parse("${baseUrl}order");
    try {
      print("api update cart-------------------");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          "address_id": address_id,
          "carts": carts,
          "payment_method": payment_method
        }),
      );
      var responseData = jsonDecode(response.body);
      if (responseData["success"] != 1) {
        return responseData['data']['message'] ?? "Có lỗi xảy ra";
      } else {
        return "OK";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<List<OrderModel>> getOrderByStatus(
      {String? searchQuery,
      String? status,
      int? page,
      int? items_per_page}) async {
    final queryParams = <String, String>{};
    if (searchQuery != null) {
      queryParams['search'] = searchQuery;
    }
    if (status != null) {
      queryParams['status'] = status;
    }
    if (page != null) {
      queryParams['page'] = page.toString();
    }
    if (items_per_page != null) {
      queryParams['items_per_page'] = items_per_page.toString();
    }
    final url = Uri.parse(
        '${baseUrl}order${queryParams.isNotEmpty ? '?' : ''}${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');
    print("API get all order: $url");

    try {
      final res = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });
      var responseData = json.decode(res.body.toString());
      if (responseData["success"] == 1) {
        List<dynamic> orderData = responseData["data"]['orders'];
        List<OrderModel> orders =
            orderData.map((dynamic item) => OrderModel.fromJson(item)).toList();
        return orders;
      } else {
        return [];
      }
    } catch (error) {
      print(error.toString());
      return [];
    }
  }

  static Future<int> getCountOrderByStatus(String status) async {
    var queryParams = '?status=$status';

    var url = Uri.parse("${baseUrl}order/count$queryParams");

    try {
      final res = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      var responseData = json.decode(res.body.toString());
      if (responseData["success"] == 1) {
        int productCount = responseData["data"];

        return productCount;
      } else {
        return 0;
      }
    } catch (error) {
      print(error.toString());
      return 0;
    }
  }

  static Future<OrderModel?> getDetailOrder(int orderId) async {
    var url = Uri.parse("${baseUrl}order/${orderId}");
    try {
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      var responseData = json.decode(res.body);

      if (responseData["success"] == 1 && responseData["data"] != null) {
        OrderModel order = OrderModel.fromJson(responseData["data"]);

        return order;
      } else {
        return null;
      }
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  static Future<String> updateStatusOrder(
      {required int orderId, required String status}) async {
    var url = Uri.parse("${baseUrl}order/status/${orderId}");
    try {
      print("api update status order $url");
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({"status": status}),
      );
      var responseData = jsonDecode(response.body);
      if (responseData["success"] != 1) {
        return responseData['data']['message'] ?? "Có lỗi xảy ra";
      } else {
        return "OK";
      }
    } catch (error) {
      debugPrint(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện";
    }
  }

  static Future<List<TopProductSellModel>> getListTopProductSell() async {
    var url = Uri.parse("${baseUrl}product/top-selling");
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
        List<dynamic> data = responseData["data"];
        List<TopProductSellModel> topProducts = data
            .map((dynamic item) => TopProductSellModel.fromJson(item))
            .toList();
        return topProducts;
      } else {
        return [];
      }
    } catch (error) {
      debugPrint(error.toString());
      return [];
    }
  }

  static Future<List<FeedbackModel>> getListFeedback({
    String? searchQuery,
    String? status,
    int? page,
    int? items_per_page,
    int? product_id,
    int? order_id,
  }) async {
    final queryParams = <String, String>{};
    if (searchQuery != null) {
      queryParams['search'] = searchQuery;
    }
    if (status != null) {
      queryParams['status'] = status;
    }
    if (page != null) {
      queryParams['page'] = page.toString();
    }
    if (items_per_page != null) {
      queryParams['items_per_page'] = items_per_page.toString();
    }
    if (product_id != null) {
      queryParams['product_id'] = product_id.toString();
    }
    if (order_id != null) {
      queryParams['order_id'] = order_id.toString();
    }
    final url = Uri.parse(
        '${baseUrl}feed-back${queryParams.isNotEmpty ? '?' : ''}${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');
    print("API get all feedback: $url");

    try {
      final res = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });
      var responseData = json.decode(res.body.toString());

      if (responseData["success"] == 1) {
        List<dynamic> feedbackData = responseData["data"]['feedbacks'];
        List<FeedbackModel> feedbacks = feedbackData
            .map((dynamic item) => FeedbackModel.fromJson(item))
            .toList();
        print("Response Data: $feedbacks");
        return feedbacks;
      } else {
        throw Exception(responseData["message"]);
      }
    } catch (error) {
      print(error.toString());
      return [];
    }
  }

  static Future<String> updateFeedback(
      int feedBackId, File file, double rating, String? comment) async {
    var url = Uri.parse("${baseUrl}feed-back/$feedBackId");
    print("run api update feedback $url");
    try {
      var request = http.MultipartRequest('PUT', url)
        ..fields['rating'] = rating.toString()
        ..fields['comment'] = comment ?? '';

      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'feedbackImage',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var decodedResponse = json.decode(responseString);
        print("dsnfsdnflksdf---------------");
        print(decodedResponse.toString());
        print("9887------------------");
        if (decodedResponse["success"] == 1) {
          return "OK";
        } else {
          return decodedResponse["message"] ??
              "Có lỗi xảy ra. Vui lòng thử lại!";
        }
      } else {
        return "Có lỗi xảy ra trong quá trình thực hiện";
      }
    } catch (error) {
      print(error.toString());
      return "Có lỗi xảy ra trong quá trình thực hiện: $error";
    }
  }

  static Future<List<FeedbackModel>> getListFeedbackPublic({
    String? searchQuery,
    String? status,
    int? page,
    int? items_per_page,
    int? product_id,
    int? order_id,
  }) async {
    final queryParams = <String, String>{};
    if (searchQuery != null) {
      queryParams['search'] = searchQuery;
    }
    if (status != null) {
      queryParams['status'] = status;
    }
    if (page != null) {
      queryParams['page'] = page.toString();
    }
    if (items_per_page != null) {
      queryParams['items_per_page'] = items_per_page.toString();
    }
    if (product_id != null) {
      queryParams['product_id'] = product_id.toString();
    }
    if (order_id != null) {
      queryParams['order_id'] = order_id.toString();
    }
    final url = Uri.parse(
        '${baseUrl}feed-back/public${queryParams.isNotEmpty ? '?' : ''}${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');
    print("API get all feedback: $url");

    try {
      final res = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });
      var responseData = json.decode(res.body.toString());

      if (responseData["success"] == 1) {
        List<dynamic> feedbackData = responseData["data"]['feedbacks'];
        List<FeedbackModel> feedbacks = feedbackData
            .map((dynamic item) => FeedbackModel.fromJson(item))
            .toList();
        print("Response Data: $feedbacks");
        return feedbacks;
      } else {
        throw Exception(responseData["message"]);
      }
    } catch (error) {
      print(error.toString());
      return [];
    }
  }

  static Future<int> getRevenue(
      {required String startDate, required String endDate}) async {
    var url = Uri.parse("${baseUrl}revenue/$startDate/$endDate");
    print("run api revenue $url");
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
        return responseData["data"]["totalRevenue"];
      } else {
        return 0;
      }
    } catch (error) {
      debugPrint(error.toString());
      return 0;
    }
  }

  static Future<List<Revenue>> getListRevenue() async {
    final url = Uri.parse('${baseUrl}revenue/six-month');
    print("API get revenue six month: $url");

    try {
      final res = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });
      var responseData = json.decode(res.body.toString());

      if (responseData["success"] == 1) {
        List<dynamic> revenueData = responseData["data"];
        List<Revenue> revenues =
            revenueData.map((dynamic item) => Revenue.fromJson(item)).toList();
        print('Revenues: $revenues');
        return revenues;
      } else {
        throw Exception(responseData["message"]);
      }
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }
}
