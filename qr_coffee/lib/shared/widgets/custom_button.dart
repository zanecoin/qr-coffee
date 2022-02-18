import 'package:flutter/material.dart';

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
    return OutlinedButton.icon(
      onPressed: () => function(),
      icon: Icon(icon, color: iconColor),
      label: Text(label, style: TextStyle(color: outlineColor, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0.0, 45.0),
        side: BorderSide(color: outlineColor, width: 1.5),
        backgroundColor: bgColor,
        shadowColor: outlineColor,
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        elevation: elevation,
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
    this.elevation = 4.0,
  }) : super(key: key);

  final Function function;
  final String label;
  final Color bgColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => function(),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(0.0, 45.0),
        side: BorderSide(color: textColor, width: 1.5),
        backgroundColor: bgColor,
        shadowColor: textColor,
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }
}
