import 'package:flutter/material.dart';

class DateRangePickerWidget extends StatefulWidget {
  @override
  _DateRangePickerWidgetState createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  DateTime? startDate;
  DateTime? endDate;

  Future<void> _selectDateRange(BuildContext context) async {
    // Thiết lập ngày mặc định là ngày hiện tại nếu startDate và endDate chưa được chọn
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : DateTimeRange(
              start: today, end: today), // Thiết lập ngày hiện tại làm mặc định
    );
    if (picked != null &&
        (picked.start != startDate || picked.end != endDate)) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _selectDateRange(context),
            child: Text('Chọn Ngày'),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                  'From: ${startDate != null ? startDate!.toIso8601String().split('T').first : todayToString()}'),
              SizedBox(width: 20),
              Text(
                  'To: ${endDate != null ? endDate!.toIso8601String().split('T').first : todayToString()}'),
            ],
          ),
        ],
      ),
    );
  }

  // Phương thức này trả về chuỗi ngày hiện tại theo định dạng yyyy-MM-dd
  String todayToString() {
    final DateTime now = DateTime.now();
    return "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}
