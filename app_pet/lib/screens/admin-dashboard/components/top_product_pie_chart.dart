import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/TopProductSell.model.dart';
import 'package:shop_app/services/api.dart';
import 'chart_sections.dart'; // Đảm bảo đã import file mới

class TopProductPieChart extends StatefulWidget {
  final String title;
  const TopProductPieChart({Key? key, required this.title}) : super(key: key);

  @override
  State<TopProductPieChart> createState() => _TopProductPieChartState();
}

class _TopProductPieChartState extends State<TopProductPieChart> {
  late List<PieChartSectionData> sections = [];
  late List<TopProductSellModel> topProducts = []; // Lưu trữ sản phẩm

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Lấy dữ liệu từ API
      final List<TopProductSellModel> fetchedTopProducts =
          await Api.getListTopProductSell();
      // Tính tổng sản phẩm đã bán
      final totalSold = fetchedTopProducts.fold<int>(
          0, (sum, item) => sum + item.productSold);

      setState(() {
        topProducts = fetchedTopProducts; // Lưu trữ dữ liệu lấy được
        sections = fetchedTopProducts.map((product) {
          // Tạo section cho PieChart
          final randomColor =
              Colors.primaries[Random().nextInt(Colors.primaries.length)];
          return createChartSectionData(
            value: product.productSold.toDouble(),
            color: randomColor,
            title:
                '${(product.productSold * 100 / totalSold).toStringAsFixed(2)}%',
            badgeColor: randomColor,
            badgeText: product.productName,
          );
        }).toList();
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            SizedBox(height: 18),
            // Thêm phần hiển thị mô tả sản phẩm ở đây:
            Expanded(
              child: ListView.builder(
                itemCount: topProducts.length,
                itemBuilder: (context, index) {
                  final product = topProducts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: sections[index].color,
                    ),
                    title: Text(product.productName),
                    subtitle: Text(
                      "Đã bán: ${product.productSold}",
                      style: TextStyle(color: kPrimaryColor),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
