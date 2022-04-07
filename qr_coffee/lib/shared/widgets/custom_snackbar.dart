import 'package:flutter/material.dart';

customSnackbar({
  required BuildContext context,
  required String text,
  int duration = 2000,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 4.0),
          Flexible(child: Text(text, style: TextStyle(color: Color(0xBBFFFFFF)))),
        ],
      ),
      duration: Duration(milliseconds: duration),
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Color.fromARGB(255, 20, 20, 26),
    ),
  );
}
