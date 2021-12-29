import 'package:flutter/material.dart';

customSnackbar({
  required BuildContext context,
  required String text,
  int duration = 2000,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: Duration(milliseconds: duration),
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
