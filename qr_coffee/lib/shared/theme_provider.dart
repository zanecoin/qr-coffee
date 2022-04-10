// we use provider to manage the app state

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  bool isLightTheme;

  ThemeProvider({required this.isLightTheme});

  isLightMode() {
    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    return brightness == Brightness.light;
  }

  // Manage the status bar and nav bar color when the theme changes.
  getCurrentStatusNavigationBarColor() {
    if (isLightMode()) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }

  toggleThemeData() async {
    final settings = await Hive.openBox('settings');
    settings.put('isLightTheme', !isLightTheme);
    isLightTheme = !isLightTheme;
    getCurrentStatusNavigationBarColor();
    notifyListeners();
  }

  // Global theme data.
  ThemeData themeData() {
    return ThemeData(
      primaryTextTheme: GoogleFonts.varelaRoundTextTheme(),
      textTheme: GoogleFonts.varelaRoundTextTheme(), //play - futuristic, cabin, varelaRound
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primarySwatch: isLightMode() ? Colors.grey : Colors.grey,
      primaryColor: isLightMode() ? Color(0xFFFFFFFF) : Color(0xFF1E1F28), //Color(0xFF1E1F28),
      brightness: isLightMode() ? Brightness.light : Brightness.dark,
      backgroundColor: isLightMode() ? Color(0xFFFFFFFF) : Color(0xFF000000), //Color(0xFF26242e),
      scaffoldBackgroundColor:
          isLightMode() ? Color(0xFFFFFFFF) : Color(0xFF000000), //Color(0xFF26242e),
      appBarTheme: AppBarTheme(
        color: isLightMode() ? Color(0xFFFFFFFF) : Color(0xFF000000),
      ),
    );
  }

  // Theme mode to display unique properties not covered in theme data.
  ThemeColor themeAdditionalData() {
    return ThemeColor(
      gradient: [
        if (isLightMode()) ...[Color(0xDDFF0080), Color(0xDDFF8C00)],
        if (!isLightMode()) ...[Color(0xFF8983F7), Color(0xFFA3DAFB)]
      ],
      textColor: isLightMode()
          ? Color.fromARGB(255, 60, 60, 70)
          : Color(0xCCFFFFFF), //Color(0xff68737d) fajna barva
      selectedColor: isLightMode() ? Color(0xFF000000) : Color(0xBBFFFFFF),
      unselectedColor: isLightMode() ? Colors.grey.shade400 : Colors.grey.shade800,
      dividerColor: isLightMode() ? Colors.grey.shade500 : Colors.grey.shade600,
      chipColor: isLightMode() ? Colors.grey.shade200 : Colors.grey.shade900,
      blendedColor: isLightMode() ? Colors.grey.shade100 : Color.fromARGB(255, 20, 20, 26),
      blendedInvertColor: isLightMode() ? Colors.grey.shade700 : Color(0xBBFFFFFF),
      backgroundColor: isLightMode() ? Color(0xFFFFFFFF) : Color(0xFF000000),
      containerColor: isLightMode() ? Color(0xFFFFFFFF) : Color.fromARGB(255, 20, 20, 26),
      buttonColor: isLightMode() ? Color(0xFFFFFFFF) : Color.fromARGB(255, 20, 20, 26),
      bannerColor: isLightMode() ? Colors.grey.shade200 : Color.fromARGB(255, 20, 20, 26),
      greenBannerColor: isLightMode() ? Colors.green.shade100 : Color.fromARGB(90, 121, 255, 126),
      redBannerColor: isLightMode() ? Colors.red.shade100 : Color.fromARGB(128, 251, 103, 118),
      blueBannerColor: isLightMode() ? Colors.blue.shade100 : Color.fromARGB(123, 102, 185, 253),
      orangeBannerColor: isLightMode() ? Colors.orange.shade100 : Color.fromARGB(152, 255, 181, 70),
      FlBorderColor:
          isLightMode() ? Color.fromARGB(255, 220, 224, 228) : Color.fromARGB(255, 59, 59, 74),
      FlTouchBarColor:
          isLightMode() ? Color.fromARGB(255, 216, 246, 244) : Color.fromARGB(255, 59, 59, 74),
      FlEvilTouchBarColor:
          isLightMode() ? Color.fromARGB(255, 240, 210, 234) : Color.fromARGB(255, 59, 59, 74),
      shadow: [
        if (isLightMode())
          BoxShadow(
              color: Color(0xFFd8d7da), spreadRadius: 0, blurRadius: 10, offset: Offset(1, 1)),
        if (!isLightMode()) BoxShadow()
      ],
    );
  }
}

// A class to manage colors and styles in the app not supported by theme data.
class ThemeColor {
  List<Color>? gradient;
  Color? selectedColor;
  Color? unselectedColor;
  Color? backgroundColor;
  Color? containerColor;
  Color? buttonColor;
  Color? bannerColor;
  Color? FlBorderColor;
  Color? FlTouchBarColor;
  Color? FlEvilTouchBarColor;
  Color? textColor;
  Color? dividerColor;
  Color? chipColor;
  Color? blendedColor;
  Color? blendedInvertColor;
  Color? greenBannerColor;
  Color? redBannerColor;
  Color? blueBannerColor;
  Color? orangeBannerColor;
  List<BoxShadow>? shadow;

  ThemeColor({
    this.gradient,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
    this.containerColor,
    this.buttonColor,
    this.bannerColor,
    this.FlBorderColor,
    this.FlTouchBarColor,
    this.FlEvilTouchBarColor,
    this.textColor,
    this.dividerColor,
    this.chipColor,
    this.blendedColor,
    this.blendedInvertColor,
    this.greenBannerColor,
    this.redBannerColor,
    this.blueBannerColor,
    this.orangeBannerColor,
    this.shadow,
  });
}
