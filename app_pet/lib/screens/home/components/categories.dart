import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/services/api.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  late Future<Map<String, dynamic>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = Api.getAllCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: FutureBuilder<Map<String, dynamic>>(
        future: categoriesFuture,
        builder: (context, snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Hiển thị loader khi đang tải
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Hiển thị lỗi nếu có
          } else {
            var categories = snapshot.data?["data"]["categories"] ?? [];
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  categories.length,
                  (index) => Padding(
                    padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                    child: CategoryCard(
                      text: categories[index]["name"],
                      press: () {
                        print(categories[index]);
                      },
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.text,
    required this.press,
  }) : super(key: key);

  final String text;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: kPrimaryColor, // Màu cam cho container
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white, // Màu chữ trắng
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(text, textAlign: TextAlign.center)
        ],
      ),
    );
  }
}
