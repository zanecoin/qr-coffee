import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

Widget animatedToggle(bool toggleValue, Function callback, ThemeProvider themeProvider) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 500),
    curve: Curves.easeOutCubic,
    height: 30.0,
    width: 70.0,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: toggleValue
          ? themeProvider.themeAdditionalData().greenBannerColor
          : themeProvider.themeAdditionalData().redBannerColor,
    ),
    child: InkWell(
      onTap: () => callback(),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOutBack,
            top: 2.5,
            left: toggleValue ? 40.0 : 0.0,
            right: toggleValue ? 0.0 : 40.0,
            child: AnimatedSwitcher(
              duration: Duration(microseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
              child: toggleValue
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 25.0,
                      key: UniqueKey(),
                    )
                  : Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                      size: 25.0,
                      key: UniqueKey(),
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget disabledAnimatedToggle() {
  return AnimatedContainer(
    duration: Duration(milliseconds: 500),
    curve: Curves.easeOutCubic,
    height: 30.0,
    width: 70.0,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      color: Colors.grey.shade200,
    ),
    child: InkWell(
      onTap: () {},
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOutBack,
            top: 2.5,
            left: 0.0,
            right: 40.0,
            child: AnimatedSwitcher(
              duration: Duration(microseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
              child: Icon(
                Icons.remove_circle_outline,
                color: Colors.grey,
                size: 25.0,
                key: UniqueKey(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
