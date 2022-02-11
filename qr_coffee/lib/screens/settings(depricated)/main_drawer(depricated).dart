import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/stats.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/widgets/custom_button_style(depricated).dart';
import 'package:qr_coffee/shared/widgets/custom_divider.dart';
import 'package:qr_coffee/shared/widgets/image_banner.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/auth.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatefulWidget {
  final Function? toggleView;

  MainDrawer({this.toggleView});

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    // get currently logged user and theme provider
    final user = Provider.of<User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (user != null) {
      return StreamBuilder<UserData>(
          stream: UserDatabase(uid: user.uid).userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserData userData = snapshot.data!;
              return Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 100, 20, 0),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            _circleAvatar(),
                            SizedBox(height: 10),
                            Text(
                              '${userData.name} ${userData.surname}',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 25, color: Colors.black),
                            ),
                            if (userData.tokens > 0)
                              Column(
                                children: [
                                  SizedBox(height: 5),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      '${userData.tokens}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 17, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: 10),
                            CustomDivider(
                              indent: 0,
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 5),
                            //CustomButton(Settings(), CzechStrings.settings,
                            //    CommunityMaterialIcons.cog_outline),
                            if (userData.role == 'worker')
                              Column(
                                children: [
                                  SizedBox(height: 5),
                                  CustomButton(Stats(), CzechStrings.stats,
                                      CommunityMaterialIcons.chart_box),
                                ],
                              ),

                            // SizedBox(height: 5),
                            // CustomButton(Help(), CzechStrings.help,
                            //     CommunityMaterialIcons.help_circle_outline),
                            SizedBox(height: 5),
                            _logout(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Loading();
            }
          });
    } else {
      return Loading();
    }
  }

  Widget _circleAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(80),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[400]!,
            offset: Offset(0, 0),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 65.0,
        child: ImageBanner(path: 'assets/cafe.jpg', size: 'small-medium'),
      ),
    );
  }

  Widget _logout() {
    return ElevatedButton.icon(
      icon: Icon(
        Icons.exit_to_app,
        color: Colors.white,
      ),
      label: Text(
        CzechStrings.logout,
        style: TextStyle(fontSize: 17, color: Colors.white),
      ),
      onPressed: () async {
        await _auth.userSignOut();
      },
      style: customButtonStyle(),
    );
  }
}

class CustomButton extends StatelessWidget {
  final Widget screen;
  final String text;
  final IconData icon;

  final Color color;

  CustomButton(
    this.screen,
    this.text,
    this.icon, {
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: TextStyle(fontSize: 17, color: Colors.white),
      ),
      onPressed: () async => Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => screen),
      ),
      style: customButtonStyle(),
    );
  }
}
