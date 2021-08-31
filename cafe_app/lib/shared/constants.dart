import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

String app_name = 'Fast Coffee';

// CUSTOM ICONS
const double icon_size = 25;
Widget waitingIcon({double size = icon_size}) => Icon(
      CommunityMaterialIcons.clock,
      color: Colors.blue,
      size: size,
    );

Widget questionIcon({double size = icon_size}) => Icon(
      Icons.help,
      color: Colors.orange,
      size: size,
    );

Widget errorIcon({double size = icon_size}) => Icon(
      Icons.cancel,
      color: Colors.red,
      size: size,
    );

Widget checkIcon({double size = icon_size}) => Icon(
      Icons.check_circle,
      color: Colors.green,
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
  static width(double p, BuildContext context) {
    return MediaQuery.of(context).size.width * (p / 100);
  }

  static height(double p, BuildContext context) {
    return MediaQuery.of(context).size.height * (p / 100);
  }
}

// CUSTOM DIVIDER
class CustomDivider extends StatelessWidget {
  final double indent;
  final double padding;
  CustomDivider({this.indent = 15, this.padding = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Divider(
        color: Colors.grey,
        thickness: 0.5,
        indent: indent,
        endIndent: indent,
      ),
    );
  }
}

// CUSTOM ALERT DIALOG
alertDialog(BuildContext context, String title, String subtitle) {
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            height: 120,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        color: Colors.blue,
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(subtitle),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      child: Text('ANO', style: TextStyle(fontSize: 14)),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      child: Text('NE', style: TextStyle(fontSize: 14)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
}
