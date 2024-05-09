import 'package:flutter/material.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/models/category.model.dart';
import 'package:shop_app/services/api.dart';

class CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final Function() onUpdated;

  const CategoryCard(
      {Key? key, required this.category, required this.onUpdated})
      : super(key: key);

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.category.name);
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cập nhật danh mục'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cập nhật'),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                String result = await Api.updateCategory(
                    widget.category.id, _controller.text);
                Navigator.of(context).pop();
                if (result == "OK") {
                  showCustomDialog(context, "Danh mục", "Cập nhật thành công");
                  widget.onUpdated();
                } else {
                  showCustomDialog(context, "Danh mục", result);
                }

                setState(() {
                  _isLoading = false;
                });
              },
            ),
            TextButton(
              child: const Text('Huỷ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xoá'),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                String result = await Api.removeCategory(widget.category.id);
                Navigator.of(context).pop();
                if (result == "OK") {
                  showCustomDialog(
                      context, "Danh mục", "Xoá danh mục thành công");
                  widget.onUpdated();
                } else {
                  showCustomDialog(context, "Danh mục", result);
                }

                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showUpdateDialog(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    widget.category.name,
                    style: const TextStyle(fontSize: 16.0),
                  ),
          ),
        ),
      ),
    );
  }
}
