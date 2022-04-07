import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar({Key? key, required this.icon}) : super(key: key);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[400]!,
            offset: Offset(0, 0),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: themeProvider.isLightMode()
            ? Colors.white
            : themeProvider.themeAdditionalData().textColor,
        radius: 50.0,
        child: Icon(icon, color: Colors.black, size: 60.0),
      ),
    );
  }
}
