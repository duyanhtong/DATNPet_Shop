import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/screens/revenue/component/revenue_chart.dart';
import 'package:shop_app/services/api.dart'; // Giả sử bạn đã định nghĩa phần này

class RevenueScreen extends StatefulWidget {
  @override
  _RevenueScreenState createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _revenue = "Chưa có doanh thu";

  Future<void> _fetchRevenue() async {
    final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate);

    try {
      final result =
          await Api.getRevenue(startDate: startDateStr, endDate: endDateStr);
      setState(() {
        _revenue = result.toString();
      });
    } catch (e) {
      setState(() {
        _revenue = "Lỗi khi tải doanh thu: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Từ ngày:'),
                TextButton(
                  onPressed: () => _selectDate(context, isStartDate: true),
                  child: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Đến ngày:'),
                TextButton(
                  onPressed: () => _selectDate(context, isStartDate: false),
                  child: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _fetchRevenue,
              child: const Text('Xem doanh thu'),
            ),
            const SizedBox(height: 16.0),
            Text('Doanh thu: $_revenue'),
            const SizedBox(height: 16.0),
            // Thêm RevenueChartWidget vào đây
            Expanded(
              child: RevenueChartWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isStartDate}) async {
    final DateTime initialDate = isStartDate ? _startDate : _endDate;
    final DateTime firstDate = isStartDate ? DateTime(2023) : _startDate;
    final DateTime lastDate = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }
}
