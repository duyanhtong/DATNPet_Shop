import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/product.model.dart';
import 'package:shop_app/models/product_variant.model.dart';
import 'package:shop_app/screens/product_detail_admin/product_detail_admin.screen.dart';
import 'package:shop_app/services/api.dart';

class ProductVariantDetailsAdminScreen extends StatefulWidget {
  final ProductVariantModel productVariant;

  const ProductVariantDetailsAdminScreen(
      {Key? key, required this.productVariant})
      : super(key: key);

  @override
  State<ProductVariantDetailsAdminScreen> createState() =>
      _ProductVariantDetailsAdminScreenState();
}

class _ProductVariantDetailsAdminScreenState
    extends State<ProductVariantDetailsAdminScreen> {
  late TextEditingController _nameController;
  late TextEditingController _productCodeController;
  late TextEditingController _priceController;
  late TextEditingController _weightController;
  late TextEditingController _discountRateController;
  late TextEditingController _inventoryController;
  FocusNode _focusNode = FocusNode();
  File? _imageProductVariant;
  bool isExpanded = false;
  bool isLoading = false;
  double opacity = 0.0;

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
    _nameController = TextEditingController(text: widget.productVariant.name);
    _priceController =
        TextEditingController(text: widget.productVariant.price.toString());
    _weightController =
        TextEditingController(text: widget.productVariant.weight.toString());
    _discountRateController = TextEditingController(
        text: widget.productVariant.discountRate.toString());
    _inventoryController =
        TextEditingController(text: widget.productVariant.inventory.toString());
    _productCodeController =
        TextEditingController(text: widget.productVariant.productCode);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          isExpanded = false;
        });
      }
    });
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

  void _updateProductVariant() async {
    _showLoadingDialog(context);
    String result = await Api.updateProductVariant(
      productVariantId: widget.productVariant.id,
      productVariantImage: _imageProductVariant,
      product_code: _productCodeController.text,
      name: _nameController.text,
      price: int.parse(_priceController.text),
      weight: int.parse(_weightController.text),
      discount_rate: int.parse(_discountRateController.text),
      inventory: int.parse(_inventoryController.text),
    );
    ProductModel product =
        await Api.getDetailProduct(widget.productVariant.productId);

    Navigator.of(context).pop();
    if (result == "OK") {
      showCustomDialog(
          context, "Sản phẩm", "Cập nhật thông tin sản phẩm thành công");
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
          "Phân loại sản phẩm",
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 16.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
                  : Image.network(
                      widget.productVariant.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return const Icon(Icons.error);
                      },
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
            //TextFormField product code
            TextFormField(
              controller: _productCodeController,
              decoration: const InputDecoration(
                labelText: "Mã Sản phẩm",
              ),
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
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
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                DiscountRateInputFormatter(),
              ],
              maxLines: isExpanded ? null : 1,
              onTap: () {
                setState(() {
                  isExpanded = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
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
                if (_imageProductVariant != null ||
                    _nameController.text.isNotEmpty ||
                    _priceController.text.isNotEmpty ||
                    _weightController.text.isNotEmpty ||
                    _discountRateController.text.isNotEmpty ||
                    _inventoryController.text.isNotEmpty) {
                  _updateProductVariant();
                } else {
                  showCustomDialog(context, "Cập nhật sản phẩm",
                      "Bạn phải thay đổi ít nhất 1 trường mới có thể cập nhật");
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _discountRateController.dispose();
    _inventoryController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _productCodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class DiscountRateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final intValue = int.tryParse(newValue.text);
    if (intValue != null && intValue > 90) {
      return oldValue;
    }
    return newValue;
  }
}
