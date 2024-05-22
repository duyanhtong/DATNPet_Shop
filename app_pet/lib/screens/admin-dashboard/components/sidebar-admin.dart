import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/services/api.dart';

class Sidebar extends StatefulWidget {
  final Function(int) onSelectItem;

  const Sidebar({Key? key, required this.onSelectItem}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: kPrimaryColor,
            ),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/mualogo.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Mưa Pet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Trang chủ'),
            onTap: () {
              widget.onSelectItem(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Quản lý đơn hàng'),
            onTap: () {
              widget.onSelectItem(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Quản lý sản phẩm'),
            onTap: () {
              widget.onSelectItem(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Quản lý danh mục'),
            onTap: () {
              widget.onSelectItem(3);
              Navigator.pop(context);
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.person),
          //   title: const Text('Quản lý người dùng'),
          //   onTap: () {
          //     widget.onSelectItem(4);
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Quản lý doanh thu'),
            onTap: () {
              widget.onSelectItem(4);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Đăng xuất'),
            onTap: () {
              Navigator.pop(context);
              Api.accessToken = null;
              Api.refreshToken = null;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/splash', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
