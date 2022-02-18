import 'dart:math';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

// 4' phone: 533x320
// 5' phone: 683x411
// 6' phone: 820x411
// Tablet: 1224x900
// Mi 9 SE: 737x360

// VALUES
double kDeviceLowerHeightTreshold = 670;
double kDeviceLowerWidthTreshold = 340;
double kDeviceUpperWidthTreshold = 600;

// CLASS FOR VARIABLE HEIGHT AND WIDTH
class Responsive {
  static double width(double p, BuildContext context) {
    return MediaQuery.of(context).size.width * (p / 100);
  }

  static double height(double p, BuildContext context) {
    return MediaQuery.of(context).size.height * (p / 100);
  }

  static double deviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double deviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static int textTreshold(BuildContext context) {
    double value = min(Responsive.deviceWidth(context), Responsive.deviceHeight(context));
    return (pow(value / 13, 0.95)).floor();
  }

  static int textTresholdShort(BuildContext context) {
    return (Responsive.deviceWidth(context) / 18).floor();
  }
}

// CUSTOM ICONS
const double icon_size = 25;
Widget waitingIcon({double size = icon_size}) => Icon(
      CommunityMaterialIcons.clock,
      color: Colors.blue.shade300,
      size: size,
    );

Widget questionIcon({double size = icon_size}) => Icon(
      Icons.help,
      color: Colors.orange.shade400,
      size: size,
    );

Widget errorIcon({double size = icon_size}) => Icon(
      Icons.cancel,
      color: Colors.red.shade400,
      size: size,
    );

Widget checkIcon({double size = icon_size, required Color color}) => Icon(
      Icons.check_circle,
      color: color,
      size: size,
    );

Widget allIcon({double size = icon_size}) => Icon(
      Icons.view_module,
      color: Colors.black,
      size: size,
    );

Widget thumbIcon({double size = icon_size}) => Icon(
      Icons.thumb_up_alt_outlined,
      color: Colors.black,
      size: size,
    );

List<String> kHours = [
  '00:00',
  '00:30',
  '01:00',
  '01:30',
  '02:00',
  '02:30',
  '03:00',
  '03:30',
  '04:00',
  '04:30',
  '05:00',
  '05:30',
  '06:00',
  '06:30',
  '07:00',
  '07:30',
  '08:00',
  '08:30',
  '09:00',
  '09:30',
  '10:00',
  '10:30',
  '11:00',
  '11:30',
  '12:00',
  '12:30',
  '13:00',
  '13:30',
  '14:00',
  '14:30',
  '15:00',
  '15:30',
  '16:00',
  '16:30',
  '17:00',
  '17:30',
  '18:00',
  '18:30',
  '19:00',
  '19:30',
  '20:00',
  '20:30',
  '21:00',
  '21:30',
  '22:00',
  '22:30',
  '23:00',
  '23:30',
];

List<String> kDaysAligned = [
  'Pondělí',
  'Úterý  ',
  'Středa ',
  'Čtvrtek',
  'Pátek  ',
  'Sobota ',
  'Neděle ',
];
