import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/screens/order/components/order_tab.component.dart';

class OrdersScreen extends StatefulWidget {
  static String routeName = "/list_order";
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/profile', (route) => false)
                }),
        title: const Text(
          'Danh sách đơn hàng',
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kPrimaryColor,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Chờ xác nhận'),
            Tab(text: 'Chờ lấy hàng'),
            Tab(text: 'Chờ giao hàng'),
            Tab(text: 'Lịch sử mua hàng'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OrdersTab(
            status: OrderStatusEnum.PendingConfirmation,
            nameTab: OrderStatusEnum.PendingConfirmation,
          ),
          OrdersTab(
            status: OrderStatusEnum.ReadyToPick,
            nameTab: OrderStatusEnum.ReadyToPick,
          ),
          OrdersTab(
            status: OrderStatusEnum.WaitingForDelivery,
            nameTab: OrderStatusEnum.WaitingForDelivery,
          ),
          OrdersTab(
            status: OrderStatusEnum.Delivered,
            nameTab: OrderStatusEnum.Delivered,
          ),
        ],
      ),
    );
  }
}
