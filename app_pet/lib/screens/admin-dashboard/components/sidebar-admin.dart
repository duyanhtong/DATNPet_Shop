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
  // 현재 선택된 인덱스를 추적할 필요가 없으므로 _selectedIndex 제거

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: kPrimaryColor,
            ),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/mualogo.png',
                    width: 80,
                    height: 80,
                  ),
                  SizedBox(width: 10),
                  Text(
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
            leading: Icon(Icons.home),
            title: Text('Trang chủ'),
            onTap: () {
              widget.onSelectItem(0); // 부모 위젯에 선택된 인덱스 전달
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Quản lý đơn hàng'),
            onTap: () {
              widget.onSelectItem(1); // 부모 위젯에 선택된 인덱스 전달
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Quản lý sản phẩm'),
            onTap: () {
              widget.onSelectItem(2); // 부모 위젯에 선택된 인덱스 전달
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('Quản lý danh mục'),
            onTap: () {
              widget.onSelectItem(3); // 부모 위젯에 선택된 인덱스 전달
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Quản lý người dùng'),
            onTap: () {
              widget.onSelectItem(4);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Đăng xuất'),
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
