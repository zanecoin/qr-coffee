import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

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

// CLASS FOR VARIABLE HEIGHT AND WIDTH
class Responsive {
  static double width(double p, BuildContext context) {
    return MediaQuery.of(context).size.width * (p / 100);
  }

  static double height(double p, BuildContext context) {
    return MediaQuery.of(context).size.height * (p / 100);
  }
}
