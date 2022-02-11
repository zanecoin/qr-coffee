import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/screens/authenticate/register.dart';
import 'package:qr_coffee/screens/authenticate/sign_in.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/shared/widgets/custom_button.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = Responsive.deviceWidth(context);

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: Responsive.height(4, context)),
                  Text(
                    CzechStrings.app_name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: Responsive.width(12, context), //60
                      fontFamily: 'Galada',
                    ),
                  ),
                  ImageBanner(path: 'assets/cafe.jpg', size: 'large'),
                  SizedBox(height: Responsive.height(4, context)),
                  Container(
                    width: deviceWidth > kDeviceUpperWidthTreshold
                        ? 400
                        : Responsive.width(60, context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CustomOutlinedButton(
                          function: pushRegister,
                          label: CzechStrings.registration1,
                        ),
                        SizedBox(height: 5.0),
                        CustomOutlinedButton(
                          function: pushSignIn,
                          label: CzechStrings.login1,
                        ),
                        SizedBox(height: 10.0),
                        SocialButton(
                          label: CzechStrings.googleLogin,
                          icon: Icon(
                            CommunityMaterialIcons.google,
                            color: Colors.white,
                          ),
                          color: Color(0xFFD04134),
                        ),
                        SizedBox(height: 10.0),
                        SocialButton(
                          label: CzechStrings.fbLogin,
                          icon: Icon(
                            CommunityMaterialIcons.facebook,
                            color: Colors.white,
                          ),
                          color: Color(0xFF3F62A9),
                        ),
                        SizedBox(height: Responsive.height(4, context)),
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

  pushRegister() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => Register()));
  }

  pushSignIn() {
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
        style: TextStyle(color: Colors.white, fontSize: 13),
      ),
      onPressed: () async {
        customSnackbar(context: context, text: CzechStrings.notImplemented);
      },
      style: customButtonStyle(color: color),
    );
  }
}
