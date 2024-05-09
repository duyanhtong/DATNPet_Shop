import 'package:flutter/material.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/category.model.dart'; // Đảm bảo rằng bạn đã định nghĩa model CategoryModel đúng cách
import 'package:shop_app/screens/category_admin/components/category_card.dart';
import 'package:shop_app/services/api.dart';

class CategoriesScreen extends StatefulWidget {
  CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<CategoryModel>> categoriesFuture;
  final TextEditingController _categoryNameController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    categoriesFuture = _fetchCategoryList();
  }

  Future<List<CategoryModel>> _fetchCategoryList() async {
    setState(() {
      isLoading = true;
    });
    final response = await Api.getAllCategory();

    if (response["success"] == true) {
      final List<dynamic> categoriesData = response["data"]["categories"];
      setState(() {
        isLoading = false;
      });
      return categoriesData
          .map<CategoryModel>((json) => CategoryModel.fromJson(json))
          .toList();
    } else {
      print(response["message"]);
      setState(() {
        isLoading = false;
      });
      return [];
    }
  }

  void _addNewCategory() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm danh mục mới'),
          content: TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(hintText: "Tên danh mục"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lưu'),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });

                var result =
                    await Api.createCategory(_categoryNameController.text);
                Navigator.of(context).pop(result);
              },
            ),
          ],
        );
      },
    ).then((result) {
      if (result == "OK") {
        showCustomDialog(context, "Danh mục", "Thêm mới thành công");
        setState(() {
          isLoading = false;
          categoriesFuture = _fetchCategoryList();
        });
      } else if (result != null) {
        showCustomDialog(context, "Danh mục", result);
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<List<CategoryModel>>(
                future: categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text(
                            "Danh sách danh mục trống. Vui lòng thử lại."));
                  } else if (snapshot.hasData) {
                    final categories = snapshot.data!;
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return CategoryCard(
                          category: categories[index],
                          onUpdated: () {
                            setState(() {
                              categoriesFuture =
                                  _fetchCategoryList(); // Làm mới dữ liệu
                            });
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(
                        child: Text(
                            "Danh sách danh mục trống. Vui lòng thử lại."));
                  }
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewCategory,
          tooltip: 'Thêm mới danh mục',
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: kPrimaryColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }
}
