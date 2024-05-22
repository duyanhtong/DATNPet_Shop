
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shop_app/services/api.dart';
import 'chart_sections.dart'; // Đảm bảo đã import file mới

class OrderPieChart extends StatefulWidget {
  final String title;
  const OrderPieChart({Key? key, required this.title}) : super(key: key);

  @override
  State<OrderPieChart> createState() => _OrderPieChartState();
}

class _OrderPieChartState extends State<OrderPieChart> {
  late List<PieChartSectionData> sections = [];
  late List<String> statusList = ["Chờ xác nhận", "Đang vận chuyển"];
  late List<int> counts = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      counts = await Future.wait(statusList.map((status) async {
        return await Api.getCountOrderByStatus(status);
      }));

      int total = counts.fold(0, (sum, count) => sum + count);

      setState(() {
        sections = counts.asMap().entries.map((entry) {
          int index = entry.key;
          int count = entry.value;
          String status = statusList[index];
          Color color = index == 0 ? Colors.red : Colors.green;
          return createChartSectionData(
            value: count.toDouble(),
            color: color,
            title: '${(count / total * 100).toStringAsFixed(0)}%',
            badgeColor: color,
            badgeText: status,
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
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 38),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.builder(
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: sections[index].color,
                    ),
                    title: Text('${statusList[index]} : ${counts[index]}'),
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
