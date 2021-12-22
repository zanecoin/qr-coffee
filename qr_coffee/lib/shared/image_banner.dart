import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/constants.dart';

class ImageBanner extends StatelessWidget {
  final String path;
  final String size;
  final Color color;

  ImageBanner(
      {required this.path, required this.size, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    double height = 85;
    double width = 55;
    switch (size) {
      case 'large':
        height = Responsive.height(30, context); //235
        width = Responsive.height(20, context); //200
        break;
      case 'medium':
        height = 120;
        width = 100;
        break;
      case 'small-medium':
        height = 100;
        width = 85;
        break;
      case 'small':
        height = Responsive.height(10, context); //70
        width = Responsive.height(8, context); //55
        break;
      case 'baby':
        height = 45;
        width = 30;
        break;
    }
    return Container(
      constraints: BoxConstraints.expand(height: height, width: width),
      decoration: BoxDecoration(color: color),
      child: Image.asset(
        path,
        fit: BoxFit.contain,
      ),
    );
  }
}
