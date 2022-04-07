import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

class CustomDivider extends StatelessWidget {
  CustomDivider({this.indent = 15, this.padding = 0, this.leftIndent = 0, this.rightIndent = 0});

  final double indent;
  final double leftIndent;
  final double rightIndent;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Divider(
        color: themeProvider.themeAdditionalData().dividerColor,
        thickness: 0.5,
        indent: leftIndent == 0 ? indent : leftIndent,
        endIndent: rightIndent == 0 ? indent : rightIndent,
      ),
    );
  }
}

class CustomDividerWithText extends StatelessWidget {
  CustomDividerWithText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = Responsive.deviceWidth(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: CustomDivider(
            padding: 10.0,
            leftIndent:
                deviceWidth < kDeviceUpperWidthTreshold ? 30.0 : Responsive.width(25.0, context),
          ),
        ),
        Text(text,
            style:
                TextStyle(fontSize: 12, color: themeProvider.themeAdditionalData().dividerColor)),
        Expanded(
          child: CustomDivider(
            rightIndent:
                deviceWidth < kDeviceUpperWidthTreshold ? 30.0 : Responsive.width(25.0, context),
          ),
        ),
      ],
    );
  }
}
