import 'package:flutter/material.dart';
import 'dashboard_card.dart'; // Đảm bảo bạn đã import đúng file DashboardCard

class DashboardCardsSection extends StatelessWidget {
  const DashboardCardsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Tất cả đơn hàng',
                icon: Icons.shopping_bag,
                status: "",
              ),
            ),
            Expanded(
              child: DashboardCard(
                title: 'Chờ xác nhận',
                icon: Icons.hourglass_bottom,
                status: "Chờ xác nhận",
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Đang Vận Chuyển',
                icon: Icons.local_shipping,
                status: "Đang giao hàng",
              ),
            ),
            Expanded(
              child: DashboardCard(
                title: 'Đã hoàn thành',
                icon: Icons.check_circle,
                status: "Giao hàng thành công",
              ),
            ),
          ],
        ),
      ],
    );
  }
}
