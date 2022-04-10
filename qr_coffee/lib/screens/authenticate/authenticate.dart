import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/screens/authenticate/register.dart';
import 'package:qr_coffee/screens/authenticate/sign_in.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      color: themeProvider.themeData().backgroundColor,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: themeProvider.themeData().backgroundColor,
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: Responsive.height(4.0, context)),
                  Text(
                    AppStringValues.app_name,
                    style: TextStyle(
                      color: themeProvider.themeAdditionalData().textColor,
                      fontSize: Responsive.width(12.0, context), //60
                      fontFamily: 'Galada',
                    ),
                  ),
                  ImageBanner(
                    path: themeProvider.isLightMode()
                        ? 'assets/cafe_transparent_black_border.png'
                        : 'assets/cafe_transparent_white_border.png',
                    size: 'large',
                    color: themeProvider.themeAdditionalData().backgroundColor!,
                  ),
                  SizedBox(height: Responsive.height(4.0, context)),
                  Container(
                    width:
                        Responsive.isLargeDevice(context) ? 400 : Responsive.width(60.0, context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CustomOutlinedButton(
                            function: _pushRegister, label: AppStringValues.registration1),
                        SizedBox(height: 5.0),
                        CustomOutlinedButton(function: _pushSignIn, label: AppStringValues.login1),
                        SizedBox(height: 10.0),
                        SocialButton(
                          label: AppStringValues.googleLogin,
                          icon: Icon(CommunityMaterialIcons.google, color: Colors.white),
                          color: themeProvider.isLightMode()
                              ? Color(0xFFD04134)
                              : Color.fromARGB(140, 208, 65, 52),
                        ),
                        SizedBox(height: 10.0),
                        SocialButton(
                          label: AppStringValues.fbLogin,
                          icon: Icon(CommunityMaterialIcons.facebook, color: Colors.white),
                          color: themeProvider.isLightMode()
                              ? Color(0xFF3F62A9)
                              : Color.fromARGB(131, 63, 98, 169),
                        ),
                        SizedBox(height: Responsive.height(4.0, context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _pushRegister() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => Register()));
  }

  _pushSignIn() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => SignIn()));
  }
}

class SocialButton extends StatelessWidget {
  final String label;
  final Icon icon;
  final Color color;
  const SocialButton({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 13.0),
      ),
      onPressed: () async {
        customSnackbar(context: context, text: AppStringValues.notImplemented);
      },
      style: customButtonStyle(color: color),
    );
  }
}
