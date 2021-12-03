import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/screens/sidebar/settings.dart';
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
      new MaterialPageRoute(builder: (context) => Settings()),
    ),
    icon: Icon(CommunityMaterialIcons.cog_outline),
  );
}

PreferredSizeWidget customAppBar(
  BuildContext context, {
  Text title = default_title,
  double elevation = 0,
  bottom = null,
  function = null,
  backArrow = true,
  actions = null,
}) {
  return AppBar(
    leading: backArrow
        ? IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 22),
            onPressed: () {
              if (function == null) {
                Navigator.pop(context);
              } else {
                function();
              }
            })
        : _settings(context),
    title: title,
    centerTitle: true,
    elevation: elevation,
    bottom: bottom,
    backgroundColor: Colors.transparent,
    actions: actions,
  );
}
