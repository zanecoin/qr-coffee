import 'package:cafe_app/screens/sidebar/help.dart';
import 'package:cafe_app/shared/image_banner.dart';
import 'package:cafe_app/shared/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/screens/sidebar/contact.dart';
import 'package:cafe_app/screens/sidebar/personal_info.dart';
import 'package:cafe_app/screens/sidebar/settings.dart';
import 'package:cafe_app/service/auth.dart';
import 'package:cafe_app/service/database.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:cafe_app/shared/loading.dart';
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
          stream: DatabaseService(uid: user.uid).userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserData userData = snapshot.data!;
              return Container(
                color: Colors.white,
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              _circleAvatar(),
                              SizedBox(height: 10),
                              Text(
                                '${userData.name} ${userData.surname}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 25, color: Colors.black),
                              ),
                              if (userData.spz.length > 0)
                                Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Text(
                                        '${userData.spz}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.black),
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
                              CustomButton(PersonalInfo(), 'Osobní údaje',
                                  CommunityMaterialIcons.account_edit_outline),
                              SizedBox(height: 5),
                              CustomButton(
                                  Help(), 'Moje karty', Icons.credit_card),
                              SizedBox(height: 5),
                              CustomButton(Settings(), 'Nastavení',
                                  CommunityMaterialIcons.cog_outline),
                              SizedBox(height: 5),
                              CustomButton(Help(), 'Nápověda',
                                  CommunityMaterialIcons.help_circle_outline),
                              SizedBox(height: 5),
                              CustomButton(Contact(), 'Kontakt', Icons.phone),
                              SizedBox(height: 5),
                              _logout(),
                            ],
                          ),
                        ],
                      ),
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
        child: ImageBanner(path: 'assets/cafe.jpg', size: 'medium'),
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
        'Odhlásit se',
        style: TextStyle(fontSize: 17, color: Colors.white),
      ),
      onPressed: () async {
        await _auth.userSignOut();
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 10),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _roleSwitch(Function toggleView) {
    return ElevatedButton.icon(
      icon: Icon(
        Icons.switch_account,
        color: Colors.white,
      ),
      label: Text(
        'Na pracovní mód',
        style: TextStyle(fontSize: 17, color: Colors.white),
      ),
      onPressed: () {
        toggleView;
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.blue.shade900,
        padding: EdgeInsets.symmetric(vertical: 10),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
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
      icon: Icon(
        icon,
        color: Colors.white,
      ),
      label: Text(
        text,
        style: TextStyle(fontSize: 17, color: Colors.white),
      ),
      onPressed: () async => Navigator.push(
          context, new MaterialPageRoute(builder: (context) => screen)),
      style: ElevatedButton.styleFrom(
        primary: color,
        padding: EdgeInsets.symmetric(vertical: 10),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
