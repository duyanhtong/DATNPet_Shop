import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/CartItem.model.dart';
import 'package:shop_app/models/feedback.model.dart';

import 'package:shop_app/models/order.model.dart';
import 'package:shop_app/screens/order/order.screen.dart';
import 'package:shop_app/services/api.dart';

class ProductReviewScreen extends StatefulWidget {
  final OrderModel order;

  ProductReviewScreen({Key? key, required this.order}) : super(key: key);

  @override
  _ProductReviewScreenState createState() => _ProductReviewScreenState();
}

class _ProductReviewScreenState extends State<ProductReviewScreen> {
  List<FeedbackModel> _feedbackList = [];
  Map<int, double> _ratings = {};
  Map<int, TextEditingController> _commentControllers = {};
  Map<int, File?> _images = {};
  final ImagePicker _picker = ImagePicker();
  String? _feedbackResult;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFeedbackList();
  }

  void _fetchFeedbackList() async {
    try {
      List<FeedbackModel> feedbackList =
          await Api.getListFeedback(order_id: widget.order.id);
      setState(() {
        _feedbackList = feedbackList;
        feedbackList.forEach((feedback) {
          _ratings[feedback.id] = 5;
          _commentControllers[feedback.id] = TextEditingController();
          _images[feedback.id] = null;
        });
      });
      _showSnackBar('Danh sách feedback đã được tải thành công');
    } catch (error) {
      _showSnackBar('Đã xảy ra lỗi khi tải danh sách feedback');
    }
  }

  Future<void> _pickImage(int feedbackId) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn nguồn ảnh'),
        actions: <Widget>[
          TextButton(
            child: const Text('Chụp ảnh'),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          TextButton(
            child: const Text('Thư viện'),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _images[feedbackId] = File(pickedFile.path);
        });
      }
    }
  }

  void _submitAllReviews() async {
    setState(() {
      _isLoading = true; // Bắt đầu hiển thị loading indicator
    });

    bool isAllFeedbacksUpdatedSuccessfully = true;

    try {
      await Future.wait(_feedbackList.map((feedback) async {
        int feedbackId = feedback.id;
        var rating = _ratings[feedbackId] ?? 0;
        var comment = _commentControllers[feedbackId]?.text;
        var file = _images[feedbackId];

        if (file != null) {
          String result =
              await Api.updateFeedback(feedbackId, file, rating, comment);
          if (result != "OK") {
            isAllFeedbacksUpdatedSuccessfully = false;
          }
        }
      }));

      if (!isAllFeedbacksUpdatedSuccessfully) {
        _showSnackBar(
            'Một hoặc nhiều phản hồi không được cập nhật thành công.');
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OrdersScreen()),
        );
      }
    } catch (error) {
      _showSnackBar('Đã xảy ra lỗi khi cập nhật phản hồi');
    } finally {
      setState(() {
        _isLoading = false; // Ẩn loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh Giá Sản Phẩm',
            style: TextStyle(fontSize: 16, color: kPrimaryColor)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.send,
              color: kPrimaryColor,
            ),
            onPressed: _isLoading ? null : _submitAllReviews,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ..._feedbackList.map((feedback) {
                    int feedbackId = feedback.id;

                    CartItem cartItem = widget.order.cartItems.firstWhere(
                      (item) =>
                          item.productVariantId == feedback.productVariantId,
                      orElse: () => CartItem(
                          id: 0,
                          productVariantId: 0,
                          productName: '',
                          productVariantName: '',
                          image:
                              "https://duyanhtest.s3.amazonaws.com/1712805381181shizuka-v-ga.jpg",
                          price: 0,
                          promotion: 0,
                          quantity: 0),
                    );
                    if (cartItem.id == 0) {
                      return const ListTile(
                        title: Text(
                          'Không tìm thấy sản phẩm',
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            '${cartItem.productName} (${cartItem.productVariantName})',
                            style: const TextStyle(fontSize: 14),
                          ),
                          leading: Image.network(
                            cartItem.image,
                            width: 50,
                            height: 50,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return const Icon(Icons.error);
                            },
                          ),
                        ),
                        StarRatingWidget(
                          onRatingSelected: (rating) {
                            setState(() {
                              _ratings[feedbackId] = rating.toDouble();
                            });
                          },
                        ),
                        TextField(
                          controller: _commentControllers[feedbackId],
                          decoration: const InputDecoration(
                              hintText: 'Nhập đánh giá của bạn...'),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 10),
                        _images[feedbackId] != null
                            ? Container(
                                width: 100,
                                height: 100,
                                child: Image.file(
                                  File(_images[feedbackId]!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () => _pickImage(feedbackId),
                          child: const Text('Thêm Ảnh'),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2), // Thời gian hiển thị của SnackBar
      ),
    );
  }
}

class StarRatingWidget extends StatefulWidget {
  final int maxRating;
  final Function(int) onRatingSelected;

  const StarRatingWidget({
    Key? key,
    this.maxRating = 5,
    required this.onRatingSelected,
  }) : super(key: key);

  @override
  _StarRatingWidgetState createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  int _currentRating = 5;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        return IconButton(
          icon: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color: kPrimaryColor,
          ),
          onPressed: () {
            setState(() {
              _currentRating = index + 1;
              widget.onRatingSelected(_currentRating);
            });
          },
        );
      }),
    );
  }
}
