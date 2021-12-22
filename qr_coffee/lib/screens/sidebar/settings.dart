import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/place.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/auth.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/widgets/animated_toggle.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:qr_coffee/shared/widgets/custom_button_style.dart';
import 'package:qr_coffee/shared/widgets/custom_divider.dart';
import 'package:qr_coffee/shared/widgets/custom_dropdown.dart';
import 'package:qr_coffee/shared/widgets/custom_text_field.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // USER
  late UserData userData;
  bool workMode = false;
  final AuthService _auth = AuthService();

  // THEME
  bool darkMode = false;
  late ThemeProvider themeProvider;

  // PLACES
  bool showPlaces = false;
  String? _currentPlace;
  late List<Place> places = [];

  // USER DATA FORM
  final _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();
  List formValues = [];

  // COMPANY INFO
  late Company company;

  @override
  Widget build(BuildContext context) {
    // get currently logged user and theme provider
    final user = Provider.of<User?>(context);
    themeProvider = Provider.of<ThemeProvider>(context);
    final double deviceWidth = Responsive.deviceWidth(context);

    if (user != null) {
      return StreamBuilder3<List<Place>, UserData, Company>(
        streams: Tuple3(
          DatabaseService().placeList,
          DatabaseService(uid: user.uid).userData,
          DatabaseService(uid: 'info_uid').company,
        ),
        builder: (context, snapshots) {
          if (snapshots.item1.hasData &&
              snapshots.item2.hasData &&
              snapshots.item3.hasData) {
            places = snapshots.item1.data!;
            userData = snapshots.item2.data!;
            company = snapshots.item3.data!;
            showPlaces = userData.stand == '' ? false : true;
            darkMode = !themeProvider.isLightTheme;
            workMode = userData.role == 'worker-off' ? false : true;

            return Scaffold(
              appBar: customAppBar(context, title: Text('')),
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // GENERAL SETTINGS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(CzechStrings.darkmode,
                              style: TextStyle(fontSize: 16)),
                          animatedToggle(darkMode, callbackTheme),
                        ],
                      ),

                      if (userData.role == 'worker-on' ||
                          userData.role == 'worker-off')
                        Column(
                          children: [
                            Text(CzechStrings.settings,
                                style: TextStyle(fontSize: 20)),
                            SizedBox(height: 10),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(CzechStrings.workMode,
                                    style: TextStyle(fontSize: 16)),
                                animatedToggle(workMode, callbackMode),
                              ],
                            ),
                          ],
                        ),

                      if (userData.role == 'worker-on')
                        Column(
                          children: [
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(CzechStrings.activateStand,
                                    style: TextStyle(fontSize: 16)),
                                _currentPlace == 'null' && userData.stand == ''
                                    ? disabledAnimatedToggle()
                                    : animatedToggle(showPlaces, callbackPlace),
                              ],
                            ),
                            SizedBox(height: 10),
                            userData.stand == ''
                                ? CustomPlaceDropdown(places, false,
                                    callbackDropdown, _currentPlace)
                                : _placeBanner(),
                          ],
                        ),
                      if (userData.role == 'worker-on' ||
                          userData.role == 'worker-off')
                        Column(
                          children: [
                            SizedBox(height: 30),
                            CustomDivider(
                              indent: 0,
                            ),
                            SizedBox(height: 30),
                          ],
                        ),

                      // PERSONAL INFO SETTINGS
                      Text(CzechStrings.personal,
                          style: TextStyle(fontSize: 20)),
                      SizedBox(height: 10),
                      Form(
                        key: _key,
                        child: Column(
                          children: <Widget>[
                            CustomTextField(
                              CzechStrings.name,
                              Icons.person_outline,
                              callbackForm,
                              initVal: userData.name,
                            ),
                            CustomTextField(
                              CzechStrings.surname,
                              Icons.person,
                              callbackForm,
                              initVal: userData.surname,
                            ),
                            SizedBox(height: 10),
                            Container(
                              child: _changeInfoBtn(
                                userData,
                                user,
                                context,
                                themeProvider,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      CustomDivider(
                        indent: 0,
                      ),
                      SizedBox(height: 30),

                      // CONTACT PANEL
                      Text(CzechStrings.contact,
                          style: TextStyle(fontSize: 20)),
                      SizedBox(height: 10),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (deviceWidth > kDeviceWidthTreshold)
                                _circleAvatar(),
                              if (deviceWidth > kDeviceWidthTreshold)
                                SizedBox(width: 20),
                              Column(
                                crossAxisAlignment:
                                    deviceWidth > kDeviceWidthTreshold
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    company.name,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${company.phone.substring(0, 4)} '
                                    '${company.phone.substring(4, 7)} '
                                    '${company.phone.substring(7, 10)} '
                                    '${company.phone.substring(10)}'
                                    '\n${company.email}'
                                    '\n${company.headquarters}',
                                    style: TextStyle(fontSize: 16),
                                    textAlign:
                                        deviceWidth > kDeviceWidthTreshold
                                            ? TextAlign.left
                                            : TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _phoneBtn(company.phone),
                              _mailBtn(company.email),
                            ],
                          ),
                          SizedBox(height: 30),
                          CustomDivider(
                            indent: 0,
                          ),
                          SizedBox(height: 30),
                          _logoutBtn(),
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
        },
      );
    } else {
      return Loading();
    }
  }

  void callbackDropdown(value) {
    _currentPlace = value;
  }

  void callbackPlace() {
    _togglePlace();
  }

  void callbackTheme() {
    _toggleTheme();
  }

  void callbackMode() {
    _toggleMode();
  }

  void callbackForm(varLabel, varValue) {
    formField[varLabel] = varValue;
  }

  // PHONE AND EMAIL LAUNCHER
  void customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    }
  }

  // CONFRIM PERSONAL INFO CHANGES
  Widget _changeInfoBtn(UserData? userData, User user, BuildContext context,
      ThemeProvider themeProvider) {
    return ElevatedButton.icon(
      icon: Icon(
        CommunityMaterialIcons.account_edit_outline,
        color: Colors.white,
      ),
      label: Text(
        CzechStrings.updatePersonal,
        style: TextStyle(fontSize: 17, color: Colors.white),
      ),
      onPressed: () async {
        setState(() {
          formValues = [];
        });

        if (_key.currentState!.validate()) {
          FocusManager.instance.primaryFocus!.unfocus();
          _key.currentState!.save();
          formField.forEach((label, value) => formValues.add(value));
          FocusManager.instance.primaryFocus!.unfocus();
          await DatabaseService(uid: user.uid).updateUserData(
            formValues[0] ?? userData!.name,
            formValues[1] ?? userData!.surname,
            userData!.email,
            userData.role,
            userData.tokens,
            userData.stand,
            userData.numOrders,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(CzechStrings.infoChangeSuccess),
              duration: Duration(milliseconds: 1200),
            ),
          );
        }
      },
      style: customButtonStyle(),
    );
  }

  // TOGGLE FOR SHOP ACTIVATION
  _togglePlace() async {
    String stand;
    bool active;
    Place? finalPlace;

    if (userData.stand == '') {
      stand = _currentPlace.toString();
      active = true;
      for (var place in places) {
        if (place.address == _currentPlace.toString()) {
          finalPlace = place;
        }
      }
    } else {
      stand = '';
      active = false;
      for (var place in places) {
        if (place.address == userData.stand) {
          finalPlace = place;
        }
      }
    }

    await DatabaseService(uid: userData.uid).updateUserData(
      userData.name,
      userData.surname,
      userData.email,
      userData.role,
      userData.tokens,
      stand,
      userData.numOrders,
    );

    try {
      await DatabaseService(uid: finalPlace!.uid)
          .updatePlaceData(finalPlace.address, finalPlace.coordinate, active);
    } catch (e) {
      print(e);
    }

    setState(() {
      showPlaces = !showPlaces;
    });
  }

  // TOGGLE FOR DARK MODE
  _toggleTheme() async {
    setState(() {
      darkMode = !darkMode;
    });
    await themeProvider.toggleThemeData();
    setState(() {});
  }

  // TOGGLE FOR WORKER/CUSTOMER MODE
  _toggleMode() async {
    String role;
    if (userData.role == 'worker-on') {
      role = 'worker-off';
    } else {
      role = 'worker-on';
    }

    await DatabaseService(uid: userData.uid)
        .updateUserData(
      userData.name,
      userData.surname,
      userData.email,
      role,
      userData.tokens,
      userData.stand,
      userData.numOrders,
    )
        .then((value) {
      setState(() {
        workMode = !workMode;
      });
    });
  }

  // WIDGET FOR PLACE BANNER
  Widget _placeBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade200,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.place,
              color: Colors.black,
              size: 25,
            ),
            SizedBox(width: 5),
            Text(
              userData.stand.length < Responsive.textTreshold(context)
                  ? ' ${userData.stand}'
                  : ' ${userData.stand.substring(0, Responsive.textTreshold(context))}...',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  Widget _circleAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50),
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
        radius: 50.0,
        child: Icon(
          Icons.store,
          color: Colors.black,
          size: 60.0,
        ),
      ),
    );
  }

  Widget _phoneBtn(String? phone) {
    return TextButton(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone, size: 35),
            Text('Zavolat', style: TextStyle(fontSize: 17)),
          ],
        ),
      ),
      onPressed: () {
        customLaunch('tel:$phone');
      },
      style: TextButton.styleFrom(primary: Colors.black),
    );
  }

  Widget _mailBtn(String? email) {
    return TextButton(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 35),
            Text('Napsat e-mail', style: TextStyle(fontSize: 17)),
          ],
        ),
      ),
      onPressed: () {
        customLaunch('mailto:$email');
      },
      style: TextButton.styleFrom(primary: Colors.black),
    );
  }

  Widget _logoutBtn() {
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
        Navigator.pop(context);
        await _auth.userSignOut();
      },
      style: customButtonStyle(),
    );
  }
}
