import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

String app_name = 'Fast Coffee';

Color light = Colors.white;
Color amber = Colors.green.shade200;
Color blue = Colors.blueAccent;
Color red = Colors.redAccent;

// CUSTOM ICONS
Widget waitingIcon({double size = 35}) => Icon(
      CommunityMaterialIcons.clock_outline,
      color: Colors.blue,
      size: size,
    );

Widget questionIcon({double size = 35}) => Icon(
      Icons.help,
      color: Colors.orange,
      size: size,
    );

Widget errorIcon({double size = 35}) => Icon(
      Icons.error,
      color: Colors.red,
      size: size,
    );

Widget checkIcon({double size = 35}) => Icon(
      Icons.check_circle,
      color: Colors.green,
      size: size,
    );

Widget allIcon({double size = 35}) => Icon(
      Icons.view_module,
      color: Colors.black,
      size: size,
    );

Widget thumbIcon({double size = 35}) => Icon(
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

// TEXT FORM FIELD TEMPLATE WITH VALIDATION
class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String initVal;
  final bool obscure;
  final String? Function(String?) validation;
  final Function callback;

  CustomTextField(this.label, this.icon, this.callback,
      {this.initVal = '',
      this.obscure = false,
      this.validation = validateText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Responsive.height(9, context),
      child: TextFormField(
        initialValue: initVal,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(
            icon,
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2.0),
          ),
        ),
        obscureText: validation == validatePassword,
        validator: validation,
        onSaved: (String? val) => callback(label, val),
      ),
    );
  }
}

String? noValidation(String? formText) {
  return null;
}

String? validateText(String? formText) {
  if (formText!.isEmpty) return 'Zadejte jméno.';

  return null;
}

String? validateEmail(String? formEmail) {
  if (formEmail!.isEmpty) return 'Zadejte e-mail.';

  String pattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail))
    return 'E-mailová adresa je v neplatném formátu.';

  return null;
}

String? validatePassword(String? formPassword) {
  if (formPassword!.isEmpty) return 'Zadejte heslo.';

  if (formPassword.length < 8) return 'Heslo musí mít minimálně 8 znaků.';

  return null;
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
                        color: blue,
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
                      color: light,
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
                      color: light,
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
