import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/Address.model.dart';
import 'package:shop_app/screens/addresses/list-address.screen.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onSelected;

  const AddressCard({
    Key? key,
    required this.address,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSelected();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Họ và tên: ${address.fullname}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text('Số điện thoại: ${address.phoneNumber}'),
              const SizedBox(height: 5),
              Text(
                'Địa chỉ: ${address.detailAddress}, ${address.ward}, ${address.district}, ${address.province}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
