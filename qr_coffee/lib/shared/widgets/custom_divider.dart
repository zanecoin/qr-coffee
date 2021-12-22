// CUSTOM DIVIDER
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double indent;
  final double padding;
  CustomDivider({this.indent = 15, this.padding = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Divider(
        color: Colors.grey,
        thickness: 0.5,
        indent: indent,
        endIndent: indent,
      ),
    );
  }
}
