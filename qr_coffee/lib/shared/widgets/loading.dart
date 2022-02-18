import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:provider/provider.dart';

class Loading extends StatefulWidget {
  Loading({this.color = Colors.blue, this.delay = true});

  final Color color;
  final bool delay;

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    int time = 0;

    if (widget.delay) {
      time = 350;
    }

    Future.delayed(Duration(milliseconds: time), () {
      if (!mounted) return;
      setState(() => loading = true);
    });

    return Container(
      color: themeProvider.themeMode().toggleBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading) SpinKitSpinningLines(color: widget.color, size: 50.0),
        ],
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
              color: themeProvider.isLightTheme ? Colors.blue : Colors.indigo,
              size: 50.0,
            ),
          ),
          Center(child: Text(AppStringValues.checkInternet)),
        ],
      ),
    );
  }
}
