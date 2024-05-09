import 'package:flutter/material.dart';
import 'package:shop_app/screens/admin-dashboard/components/dashboard_cards_section.dart';
import 'package:shop_app/screens/admin-dashboard/components/order_pie_chart.dart';
import 'package:shop_app/screens/admin-dashboard/components/top_product_pie_chart.dart';

class DashboardCardsColumn extends StatelessWidget {
  const DashboardCardsColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            DashboardCardsSection(),
            SizedBox(height: 16.0),
            SizedBox(
              height: 350,
              child: OrderPieChart(title: "Trạng thái đơn hàng"),
            ),
            SizedBox(
              height: 400,
              child: TopProductPieChart(title: "Sản phẩm bán chạy"),
            ),
          ],
        ),
      ),
    );
  }
}
