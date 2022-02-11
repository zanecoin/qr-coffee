import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/screens/app_customer/customer_settings.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';

const default_title = Text(
  CzechStrings.app_name,
  style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: 'Galada'),
);

Widget _settings(context) {
  return IconButton(
    onPressed: () => Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => CustomerSettings()),
    ),
    icon: Icon(CommunityMaterialIcons.cog_outline),
  );
}

Widget? _leading(int type, BuildContext context, Function? function) {
  if (type == 1) {
    return IconButton(
        icon: Icon(Icons.arrow_back_ios, size: 22),
        onPressed: () {
          if (function == null) {
            Navigator.pop(context);
          } else {
            function();
          }
        });
  } else if (type == 2) {
    return _settings(context);
  } else {
    return null;
  }
}

PreferredSizeWidget customAppBar(
  BuildContext context, {
  Text title = default_title,
  double elevation = 0,
  bottom = null,
  function = null,
  int type = 1,
  actions = null,
  bool centerTitle = true,
}) {
  return AppBar(
    leading: _leading(type, context, function),
    title: title,
    centerTitle: centerTitle,
    elevation: elevation,
    bottom: bottom,
    actions: actions,
  );
}
