import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

Future<dynamic> customAlertDialog(BuildContext context, Function function,
    {String title = AppStringValues.question}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: themeProvider.themeData().backgroundColor,
          ),
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      color: themeProvider.themeAdditionalData().blendedColor,
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.themeAdditionalData().textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      primary: themeProvider.themeAdditionalData().blendedInvertColor,
                      backgroundColor: themeProvider.themeAdditionalData().blendedColor,
                    ),
                    child: Text(AppStringValues.yes, style: TextStyle(fontSize: 14)),
                    onPressed: () {
                      function();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      primary: themeProvider.themeAdditionalData().blendedInvertColor,
                      backgroundColor: themeProvider.themeAdditionalData().blendedColor,
                    ),
                    child: Text(AppStringValues.no, style: TextStyle(fontSize: 14)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
