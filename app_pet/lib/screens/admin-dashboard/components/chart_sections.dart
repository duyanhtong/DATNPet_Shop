// chart_sections.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

PieChartSectionData createChartSectionData({
  required double value,
  required Color color,
  required String title,
  required Color badgeColor,
  required String badgeText,
}) {
  return PieChartSectionData(
    color: color,
    value: value,
    title: title,
    radius: 50,
    titleStyle: TextStyle(
        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
  );
}
