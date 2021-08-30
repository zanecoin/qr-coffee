import 'package:cafe_app/shared/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:cafe_app/shared/theme_provider.dart';
import 'package:provider/provider.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Container(
        color: themeProvider.themeMode().toggleBackgroundColor,
        child: SpinKitCircle(
          color: themeProvider.isLightTheme ? red : Colors.indigo,
          size: 50.0,
        ),
      ),
    );
  }
}
