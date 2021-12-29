import 'package:qr_coffee/shared/widgets/custom_button_style.dart';
import 'package:qr_coffee/shared/widgets/custom_snackbar.dart';
import 'package:qr_coffee/shared/widgets/image_banner.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/screens/authenticate/register.dart';
import 'package:qr_coffee/screens/authenticate/sign_in.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:community_material_icon/community_material_icon.dart';

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
                        AuthButton(
                          label: CzechStrings.registration1,
                          screen: Register(),
                        ),
                        SizedBox(height: 10),
                        AuthButton(
                          label: CzechStrings.login1,
                          screen: SignIn(),
                        ),
                        SizedBox(height: 10),
                        SocialButton(
                          label: CzechStrings.googleLogin,
                          icon: Icon(
                            CommunityMaterialIcons.google,
                            color: Colors.white,
                          ),
                          color: Colors.red,
                        ),
                        SizedBox(height: 10),
                        SocialButton(
                          label: CzechStrings.fbLogin,
                          icon: Icon(
                            CommunityMaterialIcons.facebook,
                            color: Colors.white,
                          ),
                          color: Colors.blue.shade700,
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
}

class AuthButton extends StatelessWidget {
  final String label;
  final StatefulWidget? screen;
  const AuthButton({
    required this.label,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(
        label,
        style: TextStyle(fontSize: 19, color: Colors.white),
      ),
      onPressed: () async {
        if (screen != null) {
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => screen!),
          );
        }
      },
      style: customButtonStyle(),
    );
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
