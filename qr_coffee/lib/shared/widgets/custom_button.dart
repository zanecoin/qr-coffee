import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

const Color textColor = Colors.black;

class CustomOutlinedIconButton extends StatelessWidget {
  const CustomOutlinedIconButton({
    Key? key,
    required this.function,
    required this.icon,
    required this.label,
    this.bgColor = Colors.white,
    this.iconColor = textColor,
    this.outlineColor = textColor,
    this.elevation = 5.0,
  }) : super(key: key);

  final Function function;
  final IconData icon;
  final String label;
  final double elevation;
  final Color bgColor;
  final Color iconColor;
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Color newOutlineColor = outlineColor == Colors.black
        ? themeProvider.themeAdditionalData().textColor!
        : outlineColor;
    Color newBgColor =
        bgColor == Colors.white ? themeProvider.themeAdditionalData().backgroundColor! : bgColor;
    double newElevation = themeProvider.isLightMode() ? elevation : 0;
    return OutlinedButton.icon(
      onPressed: () => function(),
      icon: Icon(icon, color: iconColor),
      label: Text(label, style: TextStyle(color: newOutlineColor, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0.0, 45.0),
        side: BorderSide(color: newOutlineColor, width: 1.5),
        backgroundColor: newBgColor,
        shadowColor: outlineColor,
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        elevation: newElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    Key? key,
    required this.function,
    required this.label,
    this.bgColor = Colors.white,
    this.outlineColor = textColor,
    this.elevation = 4.0,
  }) : super(key: key);

  final Function function;
  final String label;
  final Color bgColor;
  final double elevation;
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Color newOutlineColor = outlineColor == Colors.black
        ? themeProvider.themeAdditionalData().textColor!
        : outlineColor;
    Color newBgColor =
        bgColor == Colors.white ? themeProvider.themeAdditionalData().backgroundColor! : bgColor;
    double newElevation = themeProvider.isLightMode() ? elevation : 0;
    return OutlinedButton(
      onPressed: () => function(),
      child: Text(label, style: TextStyle(color: newOutlineColor, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0.0, 45.0),
        side: BorderSide(color: newOutlineColor, width: 1.5),
        backgroundColor: newBgColor,
        shadowColor: newOutlineColor,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        elevation: newElevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      ),
    );
  }
}
