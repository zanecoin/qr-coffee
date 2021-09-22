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
        child: SpinKitSpinningLines(
          color: themeProvider.isLightTheme ? Colors.red : Colors.indigo,
          size: 50.0,
        ),
      ),
    );
  }
}

class LoadingInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: themeProvider.themeMode().toggleBackgroundColor,
            child: SpinKitSpinningLines(
              color: themeProvider.isLightTheme ? Colors.red : Colors.indigo,
              size: 50.0,
            ),
          ),
          Center(child: Text('Zkontrolujte připojení k internetu ...')),
        ],
      ),
    );
  }
}
