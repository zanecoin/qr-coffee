import 'package:community_material_icon/community_material_icon.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/screens/settings/customer_settings.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

const default_title = Text(
  AppStringValues.app_name,
  style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: 'Galada'),
);

Widget _settings(context, ThemeProvider themeProvider) {
  return IconButton(
    onPressed: () => Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => CustomerSettings()),
    ),
    icon: Icon(
      CommunityMaterialIcons.cog_outline,
      color: themeProvider.themeAdditionalData().textColor,
    ),
  );
}

Widget? _leading(int type, BuildContext context, Function? function, ThemeProvider themeProvider) {
  if (type == 1) {
    return IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: 22,
          color: themeProvider.themeAdditionalData().textColor,
        ),
        onPressed: () {
          if (function == null) {
            Navigator.pop(context);
          } else {
            function();
          }
        });
  } else if (type == 2) {
    return _settings(context, themeProvider);
  } else {
    return null;
  }
}

PreferredSizeWidget customAppBar(
  BuildContext context, {
  Text? title,
  double elevation = 0,
  bottom = null,
  function = null,
  int type = 1,
  actions = null,
  bool centerTitle = true,
  Color color = Colors.white,
}) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  Color newColor = color == Colors.white
      ? themeProvider.themeData().backgroundColor
      : themeProvider.themeAdditionalData().containerColor!;
  if (title == null) {
    title = Text(
      AppStringValues.app_name,
      style: TextStyle(
        color: themeProvider.themeAdditionalData().textColor,
        fontSize: 30,
        fontFamily: 'Galada',
      ),
    );
  }
  return AppBar(
    backgroundColor: newColor,
    leading: _leading(type, context, function, themeProvider),
    title: title,
    centerTitle: centerTitle,
    elevation: elevation,
    bottom: bottom,
    actions: actions,
  );
}
