import 'package:flutter/material.dart';

const kPrimaryColor = Color.fromRGBO(255, 118, 67, 1);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Colors.black;

const kAnimationDuration = Duration(milliseconds: 200);

const headingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

const defaultPadding = 16.0;

const double exchangeRate = 25195;

const String clientIDPayPal =
    "AQrbDy3aNylV7l1k4htuiF2dqYgeY9h112kEQJU3KHJuNbfbio9Qy8dnJVsiuMq8tnDbfF4T8hfYMo8N";
const String secretKeyPayPal =
    "EMiSltda4t_AZ0-rH86fZEyfnzm7zwWNeSwlO2rotkEVTptdR6Lir6uvhmcVdzdyDMu9UF-q7zRFgAql";
// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Vui lòng nhập email của bạn";
const String kInvalidEmailError = "Email sai địng dạng";
const String kPassNullError = "Nhập mật khẩu của bạn";
const String kShortPassError = "Mật khẩu quá ngắn";
const String kMatchPassError = "Mật khẩu không hợp lệ";
const String kNamelNullError = "Vui lòng nhập tên của bạn";
const String kPhoneNumberNullError = "Nhập số điện thoại của bạn";
const String kAddressNullError = "Nhập địa chỉ của bạn";

final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 16),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: kTextColor),
  );
}

class OrderStatusEnum {
  static const String WaitingForDelivery = 'Chờ giao hàng';
  static const String PendingConfirmation = 'Chờ xác nhận';
  static const String ReadyToPick = 'Chờ lấy hàng';
  static const String Picking = 'Đang lấy hàng';
  static const String Cancel = 'Huỷ đơn hàng';
  static const String MoneyCollectPicking = 'money_collect_picking';
  static const String Picked = 'Đã lấy hàng';
  static const String Storing = 'storing';
  static const String Transporting = 'transporting';
  static const String Sorting = 'sorting';
  static const String Delivering = 'Đang giao hàng';
  static const String MoneyCollectDelivering = 'money_collect_delivering';
  static const String Delivered = 'Giao hàng thành công';
  static const String DeliveryFail = 'Giao hàng thất bại';
  static const String WaitingToReturn = 'Đợi trả hàng về cho người gửi';
  static const String Return = 'Trả hàng';
  static const String ReturnTransporting = 'Đang vận chuyển hoàn hàng';
  static const String ReturnSorting = 'return_sorting';
  static const String Returning = 'Đang hoàn hàng';
  static const String ReturnFail = 'Hoàn hàng thất bại';
  static const String Returned = 'Hoàn hàng thành công';
  static const String Exception = 'exception';
  static const String Damage = 'Hàng bị hư hỏng';
  static const String Lost = 'Hàng bị mất';

  // Prevent class instantiation
  OrderStatusEnum._();
}

extension OrderStatusColor on String {
  Color get statusColor {
    switch (this) {
      case OrderStatusEnum.WaitingForDelivery:
      case OrderStatusEnum.PendingConfirmation:
      case OrderStatusEnum.ReadyToPick:
        return Colors.blue;
      case OrderStatusEnum.Picking:
      case OrderStatusEnum.Delivering:
        return Colors.orange;
      case OrderStatusEnum.Cancel:
      case OrderStatusEnum.DeliveryFail:
      case OrderStatusEnum.ReturnFail:
      case OrderStatusEnum.Damage:
      case OrderStatusEnum.Lost:
        return Colors.red;
      case OrderStatusEnum.Delivered:
      case OrderStatusEnum.Returned:
        return Colors.green;
      case OrderStatusEnum.MoneyCollectPicking:
      case OrderStatusEnum.MoneyCollectDelivering:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

extension OrderStatusIcon on String {
  Icon get statusIcon {
    switch (this) {
      case OrderStatusEnum.WaitingForDelivery:
      case OrderStatusEnum.PendingConfirmation:
      case OrderStatusEnum.ReadyToPick:
        return Icon(Icons.hourglass_empty, color: Colors.blue);
      case OrderStatusEnum.Picking:
      case OrderStatusEnum.Delivering:
        return Icon(Icons.local_shipping, color: Colors.orange);
      case OrderStatusEnum.Cancel:
      case OrderStatusEnum.DeliveryFail:
      case OrderStatusEnum.ReturnFail:
      case OrderStatusEnum.Damage:
      case OrderStatusEnum.Lost:
        return Icon(Icons.cancel, color: Colors.red);
      case OrderStatusEnum.Delivered:
      case OrderStatusEnum.Returned:
        return Icon(Icons.check_circle, color: Colors.green);
      case OrderStatusEnum.MoneyCollectPicking:
      case OrderStatusEnum.MoneyCollectDelivering:
        return Icon(Icons.attach_money, color: Colors.purple);
      default:
        return Icon(Icons.help_outline, color: Colors.grey);
    }
  }
}
