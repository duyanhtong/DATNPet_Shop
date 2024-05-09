import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/components/dialog_loading.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/product.model.dart';
import 'package:shop_app/models/product_variant.model.dart';
import 'package:shop_app/screens/product_detail_admin/product_detail_admin.screen.dart';
import 'package:shop_app/services/api.dart';

class AddProductVariantScreen extends StatefulWidget {
  final int productId;

  const AddProductVariantScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  State<AddProductVariantScreen> createState() =>
      _AddProductVariantScreenState();
}

class _AddProductVariantScreenState extends State<AddProductVariantScreen> {
  late TextEditingController _nameController;
  late TextEditingController _productCodeController;
  late TextEditingController _priceController;
  late TextEditingController _weightController;
  late TextEditingController _discountRateController;
  late TextEditingController _inventoryController;
  FocusNode _focusNode = FocusNode();
  File? _imageProductVariant;
  bool isExpanded = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageProductVariant = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _productCodeController = TextEditingController();
    _priceController = TextEditingController();
    _weightController = TextEditingController();
    _discountRateController = TextEditingController();
    _inventoryController = TextEditingController();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          isExpanded = false;
        });
      }
    });
  }

  void _addProductVariant() async {
    DialogUtils.showLoadingDialog(context);
    String result = await Api.createProductVariant(
      productId: widget.productId,
      name: _nameController.text,
      product_code: _productCodeController.text,
      price: int.parse(_priceController.text),
      weight: int.parse(_weightController.text),
      discount_rate: _discountRateController.text.isNotEmpty
          ? int.parse(_discountRateController.text)
          : 0,
      inventory: int.parse(_inventoryController.text),
      productVariantImage: _imageProductVariant,
    );
    ProductModel product = await Api.getDetailProduct(widget.productId);

    Navigator.of(context).pop();
    if (result == "OK") {
      showCustomDialog(
          context, "Phân loại sản phẩm", "Thêm phân loại sản phẩm thành công");
      await Future.delayed(const Duration(seconds: 3));
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProductDetailsAdminScreen(product: product),
        ),
      );
    } else {
      showCustomDialog(context, "Sản phẩm", result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thêm mới phân loại sản phẩm",
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
            //hiển thị hình ảnh
            SizedBox(
              height: MediaQuery.of(context).size.height / 6,
              child: _imageProductVariant != null
                  ? Image.file(
                      _imageProductVariant!,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/mưa1.png',
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
            //TextFormField mã sản phẩm
            TextFormField(
              controller: _productCodeController,
              decoration: const InputDecoration(
                labelText: "Mã sản phẩm",
              ),
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  _productCodeController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _productCodeController.text.length,
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
            //TextFormField tên phân loại
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Tên phân loại",
              ),
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance!.addPostFrameCallback((_) {
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
            // TextFormField giá tiền
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "Giá tiền",
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  _priceController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _priceController.text.length,
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
            // TextFormField cân nặng
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: "Khối lượng",
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  _weightController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _weightController.text.length,
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
            // TextFormField Giảm giá
            TextFormField(
              controller: _discountRateController,
              decoration: const InputDecoration(
                labelText: "Giảm giá",
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  _discountRateController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _discountRateController.text.length,
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
            // TextFormField Sô lượng tồn kho
            TextFormField(
              controller: _inventoryController,
              decoration: const InputDecoration(
                labelText: "Số lượng tồn kho",
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  _inventoryController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _inventoryController.text.length,
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
            ElevatedButton(
              onPressed: () {
                if (_imageProductVariant != null &&
                    _nameController.text.isNotEmpty &&
                    _productCodeController.text.isNotEmpty &&
                    _priceController.text.isNotEmpty &&
                    _weightController.text.isNotEmpty &&
                    _inventoryController.text.isNotEmpty) {
                  _addProductVariant();
                } else {
                  showCustomDialog(context, "Thêm mới phân loại sản phẩm",
                      "Bạn phải điền đầy đủ thông tin để thêm sản phẩm");
                }
              },
              child: const Text('Thêm mới'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _productCodeController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _discountRateController.dispose();
    _inventoryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
