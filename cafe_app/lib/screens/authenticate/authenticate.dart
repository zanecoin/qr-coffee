import 'package:cafe_app/shared/image_banner.dart';
import 'package:flutter/material.dart';
import 'package:cafe_app/screens/authenticate/register.dart';
import 'package:cafe_app/screens/authenticate/sign_in.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:community_material_icon/community_material_icon.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Container(
                  color: Colors.white,
                ),
                Container(
                  width: Responsive.width(100, context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: Responsive.height(4, context)),
                      Text(
                        app_name,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 60,
                            fontFamily: 'Galada'),
                      ),
                      ImageBanner('assets/cafe.jpg'),
                      SizedBox(height: Responsive.height(4, context)),
                      Container(
                        width: Responsive.width(60, context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            ElevatedButton(
                              child: Text(
                                'Registrace',
                                style: TextStyle(
                                    fontSize: 19, color: Colors.white),
                              ),
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => Register()));
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.black,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                            ),
                            SizedBox(height: Responsive.height(1, context)),
                            ElevatedButton(
                              child: Text(
                                'Přihlášení',
                                style: TextStyle(
                                    fontSize: 19, color: Colors.white),
                              ),
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => SignIn()));
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.black,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton.icon(
                              icon: Icon(CommunityMaterialIcons.google,
                                  color: Colors.white),
                              label: Text(
                                'Pokračovat přes Google',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                              onPressed: () async {},
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton.icon(
                              icon: Icon(CommunityMaterialIcons.facebook,
                                  color: Colors.white),
                              label: Text(
                                'Pokračovat přes Facebook',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                              onPressed: () async {},
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
