import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/product.model.dart';
import 'package:shop_app/models/product_variant.model.dart';
import 'package:shop_app/screens/product_admin/product_admin.screen.dart';
import 'package:shop_app/screens/product_variant_admin/add-product_variant_admin.screen.dart';
import 'package:shop_app/screens/product_variant_admin/product_variant_admin.screen.dart';
import 'package:shop_app/services/api.dart';

class ProductDetailsAdminScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsAdminScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailsAdminScreen> createState() =>
      _ProductDetailsAdminScreenState();
}

class _ProductDetailsAdminScreenState extends State<ProductDetailsAdminScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _ingredientController;
  late TextEditingController _originController;
  late TextEditingController _brandController;
  late TextEditingController _unitController;
  late TextEditingController _isBestSellerController;

  // Biến thể sản phẩm
  late List<TextEditingController> _variantNameControllers;
  late List<TextEditingController> _productCodeControllers;
  late List<TextEditingController> _priceControllers;
  late List<TextEditingController> _discountRateControllers;
  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _inventoryControllers;

  bool isExpanded = false;
  bool isLoading = false;
  double opacity = 0.0;
  late int _isFlashSaleValue;
  FocusNode _focusNode = FocusNode();
  final List<String> unitOptions = ['Gói', 'Túi', 'Bao', "Hộp", "Tuỳ Size"];

  File? _imageProduct;
  bool isFlashSale = false;
  String selectedUnit = "Tuỳ Size";
  late List<Map<String, dynamic>> _categoryList = [];
  int? _selectedCategoryId;

  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageProduct = File(pickedFile.path);
      });
    }
  }

  Future<void> _fetchCategoryList() async {
    final response = await Api.getAllCategory();
    if (response["success"] == true) {
      final List<dynamic> categoriesData = response["data"]["categories"];
      final List<Map<String, dynamic>> categoriesList =
          List<Map<String, dynamic>>.from(categoriesData);
      setState(() {
        _categoryList = categoriesList;
      });
    } else {
      // Handle API error
      print(response["message"]);
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Đang cập nhật sản phẩm...'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _ingredientController =
        TextEditingController(text: widget.product.ingredient);
    _originController = TextEditingController(text: widget.product.origin);
    _brandController = TextEditingController(text: widget.product.brand);
    _unitController = TextEditingController(text: widget.product.unit);
    _isBestSellerController =
        TextEditingController(text: widget.product.isBestSeller.toString());
    // Khởi tạo controllers cho từng biến thể
    _variantNameControllers = widget.product.productVariant
        .map((variant) => TextEditingController(text: variant.name))
        .toList();
    _productCodeControllers = widget.product.productVariant
        .map((variant) => TextEditingController(text: variant.productCode))
        .toList();
    _priceControllers = widget.product.productVariant
        .map((variant) => TextEditingController(text: variant.price.toString()))
        .toList();
    _discountRateControllers = widget.product.productVariant
        .map((variant) =>
            TextEditingController(text: variant.discountRate.toString()))
        .toList();
    _weightControllers = widget.product.productVariant
        .map((variant) => variant.weight != null
            ? TextEditingController(text: variant.weight.toString())
            : TextEditingController())
        .toList();
    _inventoryControllers = widget.product.productVariant
        .map((variant) =>
            TextEditingController(text: variant.inventory.toString()))
        .toList();
    isFlashSale = widget.product.isBestSeller == 1;
    selectedUnit = widget.product.unit ?? "Tuỳ Size";

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          isExpanded = false;
        });
      }
    });
    _fetchCategoryList();
    _selectedCategoryId = widget.product.category_id;
    selectedUnit = unitOptions.contains(widget.product.unit ?? "Tuỳ Size")
        ? widget.product.unit ?? "Tuỳ Size"
        : unitOptions.first;
  }

  void _updateProduct() async {
    _showLoadingDialog(context);
    _isFlashSaleValue = isFlashSale ? 1 : 0;
    String result = await Api.updateProduct(
      productId: widget.product.id,
      productImage: _imageProduct,
      productName: _nameController.text,
      description: _descriptionController.text,
      ingredient: _ingredientController.text,
      origin: _originController.text,
      brand: _brandController.text,
      unit: selectedUnit,
      is_best_seller: _isFlashSaleValue,
      category_id: _selectedCategoryId ?? widget.product.category_id,
    );
    Navigator.of(context).pop();

    if (result == "OK") {
      showCustomDialog(
          context, "Sản phẩm", "Cập nhật thông tin sản phẩm thành công");
      await Future.delayed(const Duration(seconds: 3));
    } else {
      showCustomDialog(context, "Sản phẩm", result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chi tiết sản phẩm",
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 16.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // hiển thị image product
            SizedBox(
              height: MediaQuery.of(context).size.height / 6,
              child: _imageProduct != null
                  ? Image.file(
                      _imageProduct!,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      widget.product.imagePath,
                      fit: BoxFit.cover,
                    ),
            ),
            // hiển thị icon chọn ảnh
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PopupMenuButton(
                  icon: const Icon(Icons.add_a_photo),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Chọn ảnh từ thư viện'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Chụp ảnh'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            // TextFormField tên sản phẩm
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Tên sản phẩm",
              ),
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _nameController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _nameController.text.length,
                  );
                });
              },
              onFieldSubmitted: (value) {
                setState(() {
                  isExpanded = false;
                });
              },
            ),
            const SizedBox(height: 10.0),
            //TextFormField Mô tả
            TextFormField(
              controller: _descriptionController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                labelText: "Mô tả",
              ),
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _descriptionController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _descriptionController.text.length,
                  );
                });
              },
              onFieldSubmitted: (value) {
                setState(() {
                  isExpanded = false;
                });
              },
            ),
            const SizedBox(height: 10.0),
            //TextFormField Thành phần
            TextFormField(
              controller: _ingredientController,
              decoration: const InputDecoration(
                labelText: "Thành phần",
              ),
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _ingredientController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _ingredientController.text.length,
                  );
                });
              },
              onFieldSubmitted: (value) {
                setState(() {
                  isExpanded = false;
                });
              },
            ),
            const SizedBox(height: 10.0),
            //TextFormField xuất xứ
            TextFormField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: "Xuất xứ",
              ),
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _originController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _originController.text.length,
                  );
                });
              },
              onFieldSubmitted: (value) {
                setState(() {
                  isExpanded = false;
                });
              },
            ),
            const SizedBox(height: 10.0),
            //TextFormField thương hiệu
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: "Thương hiệu",
              ),
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _brandController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _brandController.text.length,
                  );
                });
              },
              onFieldSubmitted: (value) {
                setState(() {
                  isExpanded = false;
                });
              },
            ),
            const SizedBox(height: 10.0),
            // dropdowm chọn unit product
            DropdownButtonFormField<String>(
              value: selectedUnit,
              items: unitOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedUnit = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Đơn vị',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            // check box is best seller
            Row(
              children: [
                Checkbox(
                  value: isFlashSale,
                  onChanged: (value) {
                    setState(() {
                      isFlashSale = value!;
                    });
                  },
                ),
                const Text('Flash Sale'),
              ],
            ),
            const SizedBox(height: 10.0),
            // dropdown chọn category
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              items: _categoryList.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategoryId = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Danh mục sản phẩm',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            // Text phân loại sản phẩm
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 24,
                    color: kPrimaryColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Phân loại sản phẩm",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor),
                  ),
                ],
              ),
            ),
// list card product variant
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...widget.product.productVariant.map((variant) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductVariantDetailsAdminScreen(
                              productVariant: variant,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 150, // Độ rộng của mỗi card product variant
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  variant.imagePath,
                                  fit: BoxFit.cover,
                                  height: 100,
                                ),
                              ),
                              Text(
                                variant.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('Price: ${variant.price}'),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  // Card cuối cùng để thêm mới product variant
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddProductVariantScreen(
                              productId: widget.product.id),
                        ),
                      );
                    },
                    child: Container(
                      width: 150, // Độ rộng của nút thêm
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: const Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            Text(
                              'Thêm mới',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            // button lưu
            ElevatedButton(
              onPressed: () {
                if (_imageProduct != null ||
                    _nameController.text.isNotEmpty ||
                    _descriptionController.text.isNotEmpty ||
                    _ingredientController.text.isNotEmpty ||
                    _originController.text.isNotEmpty ||
                    _brandController.text.isNotEmpty ||
                    isFlashSale) {
                  _updateProduct();
                } else {
                  showCustomDialog(context, "Cập nhật sản phẩm",
                      "Bạn phải thay đổi ít nhất 1 trường mới có thể cập nhật");
                }
              },
              child: const Text('Lưu'),
            ),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: opacity,
              child: const Center(
                child:
                    CircularProgressIndicator(), // Hiển thị vòng tròn tiến trình với độ mờ thay đổi
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ingredientController.dispose();
    _originController.dispose();
    _brandController.dispose();
    _unitController.dispose();
    _isBestSellerController.dispose();

    for (var controller in _variantNameControllers) {
      controller.dispose();
    }
    for (var controller in _productCodeControllers) {
      controller.dispose();
    }
    for (var controller in _priceControllers) {
      controller.dispose();
    }
    for (var controller in _discountRateControllers) {
      controller.dispose();
    }
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    for (var controller in _inventoryControllers) {
      controller.dispose();
    }

    _focusNode.dispose();
    super.dispose();
  }
}
