import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';

class CustomTextBanner extends StatelessWidget {
  const CustomTextBanner({
    Key? key,
    required this.title,
    this.showIcon = true,
    this.icon = Icons.person,
  }) : super(key: key);

  final String title;
  final bool showIcon;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = Responsive.deviceWidth(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.0),
      width: deviceWidth > kDeviceUpperWidthTreshold ? Responsive.width(60.0, context) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey.shade200,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) Icon(icon, color: Colors.black, size: 25.0),
            SizedBox(width: 5.0),
            Text(
              cutTextIfNeccessary(title, Responsive.textTreshold(context)),
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
            SizedBox(width: 5.0),
          ],
        ),
      ),
    );
  }
}
