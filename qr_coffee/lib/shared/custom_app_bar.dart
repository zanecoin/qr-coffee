import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';

const default_title = Text(
  CzechStrings.app_name,
  style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: 'Galada'),
);

PreferredSizeWidget customAppBar(
  BuildContext context, {
  Text title = default_title,
  double elevation = 5,
  bottom = null,
  function = null,
}) {
  return AppBar(
    leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, size: 22),
        onPressed: () {
          if (function == null) {
            Navigator.pop(context);
          } else {
            function();
          }
        }),
    title: title,
    centerTitle: true,
    elevation: elevation,
    bottom: bottom,
  );
}
