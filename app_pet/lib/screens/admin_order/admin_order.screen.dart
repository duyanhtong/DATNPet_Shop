import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/screens/order/components/order_tab.component.dart';

class AdminOrdersScreen extends StatefulWidget {
  static String routeName = "/list_order_admin";

  @override
  _AdminOrderScreenState createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrdersScreen>
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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: TabBar(
                controller: _tabController,
                indicatorColor: kPrimaryColor,
                labelColor: kPrimaryColor,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Chờ xác nhận'),
                  Tab(text: 'Chờ lấy hàng'),
                  Tab(text: 'Chờ giao hàng'),
                  Tab(text: 'Lịch sử mua hàng'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  OrdersTab(
                    status: OrderStatusEnum.PendingConfirmation,
                    isButton: false,
                    isAdmin: true,
                    nameTab: OrderStatusEnum.PendingConfirmation,
                  ),
                  OrdersTab(
                    status: OrderStatusEnum.ReadyToPick,
                    isButton: false,
                    isAdmin: true,
                    nameTab: OrderStatusEnum.ReadyToPick,
                  ),
                  OrdersTab(
                    status: OrderStatusEnum.WaitingForDelivery,
                    isButton: false,
                    isAdmin: true,
                    nameTab: OrderStatusEnum.WaitingForDelivery,
                  ),
                  OrdersTab(
                    status: OrderStatusEnum.Delivered,
                    isButton: false,
                    isAdmin: true,
                    nameTab: OrderStatusEnum.Delivered,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
