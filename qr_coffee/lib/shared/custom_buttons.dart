import 'package:flutter/material.dart';

ButtonStyle customButtonStyle(
    {Color color = Colors.black87, double elevation = 4}) {
  return ElevatedButton.styleFrom(
    primary: color,
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
    elevation: elevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );
}
