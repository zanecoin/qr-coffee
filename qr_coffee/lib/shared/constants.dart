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
  '00',
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  '23',
  '24'
];

List<String> kMinutes = ['00', '30'];
