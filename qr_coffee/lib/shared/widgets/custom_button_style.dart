import 'package:flutter/material.dart';

ButtonStyle customButtonStyle({
  Color color = Colors.black,
  double elevation = 4,
  double? fontSize = null,
}) {
  return ElevatedButton.styleFrom(
    primary: color,
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
    elevation: elevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    textStyle: TextStyle(fontSize: fontSize),
  );
}
