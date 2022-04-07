import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

Future<dynamic> customOptionDialog(
  Function function,
  List<String> options,
  BuildContext context,
  BuildContext generalContext,
  UserRole previousRole,
  String userID,
) {
  final double deviceWidth = Responsive.deviceWidth(context);
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: AspectRatio(
          aspectRatio: 1.4,
          child: Container(
            height: 50,
            // deviceWidth > kDeviceUpperWidthTreshold ? Responsive.width(60.0, context) : null,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: themeProvider.themeAdditionalData().blendedColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _textButton(function, context, generalContext, options[0], previousRole, userID,
                    themeProvider),
                _textButton(function, context, generalContext, options[1], previousRole, userID,
                    themeProvider),
                _textButton(function, context, generalContext, options[2], previousRole, userID,
                    themeProvider),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _textButton(
  Function function,
  BuildContext context,
  BuildContext generalContext,
  String futureRole,
  UserRole previousRole,
  String userID,
  ThemeProvider themeProvider,
) {
  return TextButton(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      primary: themeProvider.themeAdditionalData().blendedInvertColor,
      backgroundColor: themeProvider.themeAdditionalData().backgroundColor,
    ),
    child: Text(futureRole, style: TextStyle(fontSize: 16.0)),
    onPressed: () {
      function(futureRole, previousRole, generalContext, userID);
      Navigator.pop(context);
    },
  );
}
