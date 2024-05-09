import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/responsive.dart';

import 'package:shop_app/screens/admin-dashboard/components/dashboard_card.dart';
import 'package:shop_app/screens/admin-dashboard/components/dashboard_cards_column.dart';
import 'package:shop_app/screens/admin-dashboard/components/search_field-admin.component.dart';
import 'package:shop_app/screens/admin-dashboard/components/sidebar-admin.dart';
import 'package:shop_app/screens/admin_order/admin_order.screen.dart';
import 'package:shop_app/screens/category_admin/category_admin.screen.dart';
import 'package:shop_app/screens/home/components/search_field.dart'; // Import SearchField widget
import 'package:shop_app/screens/admin-dashboard/components/account_icon.dart';
import 'package:shop_app/screens/product_admin/product_admin.screen.dart'; // Import AccountIcon widget

class DashboardScreen extends StatefulWidget {
  static String routeName = "/dashboard";

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = [
    DashboardCardsColumn(),
    AdminOrdersScreen(),
    ProductManagementScreen(),
    CategoriesScreen(),
    Text("Quản lý người dùng"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Theme.of(context).primaryColor),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: const <Widget>[
          SearchFieldAdmin(),
          AccountIcon(),
        ],
        backgroundColor: Colors.white,
      ),
      drawer: Sidebar(
        onSelectItem: _onItemSelect,
      ),
      body: _screens[_selectedIndex],
    );
  }
}
