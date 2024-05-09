import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';

class IconTextPadding extends StatelessWidget {
  final IconData? icon;
  final String text;
  final double iconSize;
  final double spacing;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight; // 여기에 fontWeight 추가

  const IconTextPadding({
    Key? key,
    this.icon,
    required this.text,
    this.iconSize = 24.0,
    this.spacing = 8.0,
    this.color = kPrimaryColor,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.bold, // 기본값 설정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color,
              size: iconSize,
            ),
            SizedBox(width: spacing),
          ],
          Text(
            text,
            style: TextStyle(
              fontWeight: fontWeight,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
