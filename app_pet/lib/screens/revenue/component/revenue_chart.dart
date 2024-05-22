import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/Revenue.model.dart';
import 'dart:convert';

import 'package:shop_app/services/api.dart';

class RevenueChartWidget extends StatefulWidget {
  @override
  _RevenueChartWidgetState createState() => _RevenueChartWidgetState();
}

class _RevenueChartWidgetState extends State<RevenueChartWidget> {
  final List<BarChartGroupData> barGroups = [];
  List<Revenue> monthlyRevenues = [];

  @override
  void initState() {
    super.initState();
    fetchAndSetRevenues();
  }

  Future<void> fetchAndSetRevenues() async {
    monthlyRevenues = await Api.getListRevenue();

    monthlyRevenues.asMap().forEach((i, revenue) {
      final barGroup = BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: revenue.totalRevenue.toDouble(),
            color: Colors.orange, // 막대 색상을 오렌지색으로 변경
          ),
        ],
        showingTooltipIndicators: [0],
      );
      barGroups.add(barGroup);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: monthlyRevenues.isNotEmpty
                ? monthlyRevenues
                        .map((e) => e.totalRevenue)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() +
                    10.0
                : 0,
            barGroups: barGroups,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < monthlyRevenues.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          monthlyRevenues[value.toInt()].month,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                          ),
                        ),
                      );
                    } else {
                      return const Text('');
                    }
                  },
                  reservedSize: 40,
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }
}
