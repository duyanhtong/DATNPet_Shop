import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/product.model.dart';

import 'package:shop_app/models/product_variant.model.dart';
import 'package:shop_app/services/api.dart';

class AddProductScreen extends StatefulWidget {
  static String routeName = "/add_product";
  const AddProductScreen({super.key});
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _ingredientController;
  late TextEditingController _originController;
  late TextEditingController _brandController;
  late TextEditingController _unitController;
  late TextEditingController _isBestSellerController;
  late TextEditingController _ratingController;
  late TextEditingController _soldController;
  late TextEditingController _categoryIdController;
  late TextEditingController _imagePathController;

  late TextEditingController _variantNameController;
  late TextEditingController _productCodeController;
  late TextEditingController _priceController;
  late TextEditingController _discountRateController;
  late TextEditingController _weightController;
  late TextEditingController _inventoryController;
  late TextEditingController _variantImagePathController;

  bool isExpanded = false;
  bool isLoading = false;
  double opacity = 0.0;

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
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _ingredientController = TextEditingController();
    _originController = TextEditingController();
    _brandController = TextEditingController();
    _unitController = TextEditingController();
    _isBestSellerController = TextEditingController();
    _ratingController = TextEditingController();
    _soldController = TextEditingController();
    _categoryIdController = TextEditingController();
    _imagePathController = TextEditingController();

    _variantNameController = TextEditingController();
    _productCodeController = TextEditingController();
    _priceController = TextEditingController();
    _discountRateController = TextEditingController();
    _weightController = TextEditingController();
    _inventoryController = TextEditingController();
    _variantImagePathController = TextEditingController();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          isExpanded = false;
        });
      }
    });
    _fetchCategoryList();
  }

  void _submitForm() async {
    // Show loading dialog
    _showLoadingDialog(context);

    if (_imageProduct != null &&
        _nameController.text.isNotEmpty &&
        _selectedCategoryId != null) {
      final String result = await Api.createProduct(
        productImage: _imageProduct!,
        productName: _nameController.text,
        description: _descriptionController.text,
        ingredient: _ingredientController.text,
        origin: _originController.text,
        brand: _brandController.text,
        unit: selectedUnit,
        category_id: _selectedCategoryId!,
      );
      Navigator.pop(context);
      if (result == "OK") {
        showCustomDialog(context, "Sản phẩm", "Thêm mới sản phẩm thành công");
        await Future.delayed(const Duration(seconds: 3));
      } else {
        showCustomDialog(context, "Sản phẩm", result);
      }
    } else {
      Navigator.pop(context);
      showCustomDialog(context, "Thêm mới sản phẩm",
          "Bạn cần điền đầy đủ thông tin sản phẩm");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm mới sản phẩm',
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 16.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // hiển thị image product
              SizedBox(
                height: MediaQuery.of(context).size.height / 6,
                child: _imageProduct != null
                    ? Image.file(
                        _imageProduct!,
                        fit: BoxFit.cover,
                      )
                    : Image.asset("assets/images/2.png"),
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

              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Thêm sản phẩm'),
              ),
            ],
          ),
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
    _ratingController.dispose();
    _soldController.dispose();
    _categoryIdController.dispose();
    _imagePathController.dispose();

    _variantNameController.dispose();
    _productCodeController.dispose();
    _priceController.dispose();
    _discountRateController.dispose();
    _weightController.dispose();
    _inventoryController.dispose();
    _variantImagePathController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
