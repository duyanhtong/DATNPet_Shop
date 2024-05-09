import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/Address.model.dart';

class AddressCart extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final VoidCallback onSelected;
  final Function(int) onUpdate;

  const AddressCart({
    Key? key,
    required this.address,
    required this.isSelected,
    required this.onSelected,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: ListTile(
        leading: Radio(
            value: address.id,
            groupValue: isSelected ? address.id : null,
            onChanged: (_) {
              onSelected();
              onUpdate(address.id);
            },
            activeColor: kPrimaryColor),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Họ và tên: ${address.fullname}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('Số điện thoại: ${address.phoneNumber}'),
            SizedBox(height: 5),
            Text(
              'Địa chỉ: ${address.detailAddress}, ${address.ward}, ${address.district}, ${address.province}',
            ),
          ],
        ),
      ),
    );
  }
}
