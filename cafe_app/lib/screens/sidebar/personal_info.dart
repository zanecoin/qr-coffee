import 'package:cafe_app/shared/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/service/database.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:cafe_app/shared/loading.dart';
import 'package:cafe_app/shared/theme_provider.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:provider/provider.dart';

class PersonalInfo extends StatefulWidget {
  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();

  // form values
  List formValues = [];

  @override
  Widget build(BuildContext context) {
    // get currently logged user and theme provider
    final user = Provider.of<User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // get data streams
    if (user != null) {
      return StreamBuilder<UserData>(
          stream: DatabaseService(uid: user.uid).userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserData? userData = snapshot.data;

              return Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                        icon: Icon(Icons.arrow_back_ios, size: 22),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    title: Text(
                      'Osobní údaje',
                    ),
                    centerTitle: true,
                    elevation: 5,
                  ),
                  body: Builder(builder: (BuildContext context) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: themeProvider.isLightTheme
                                  ? Colors.white
                                  : Color(0xFF1E1F28),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[500]!,
                                  offset: themeProvider.isLightTheme
                                      ? Offset(1, 1)
                                      : Offset(0, 0),
                                  blurRadius:
                                      themeProvider.isLightTheme ? 3 : 0,
                                )
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 40, horizontal: 40),
                            margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Form(
                              key: _key,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        CustomTextField('Jméno',
                                            Icons.person_outline, callback,
                                            initVal: userData!.name),
                                        CustomTextField(
                                            'Příjmení', Icons.person, callback,
                                            initVal: userData.surname),
                                        SizedBox(height: 10),
                                        Text(
                                          'Pro expresní vyzvednutí objednávky ponechte vaši SPZ vyplněnou:',
                                          textAlign: TextAlign.left,
                                        ),
                                        SizedBox(height: 10),
                                        CustomTextField(
                                            'Státní poznávací značka',
                                            Icons.person,
                                            callback,
                                            validation: noValidation,
                                            initVal: userData.spz),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                    Container(
                                      // padding:
                                      //     EdgeInsets.symmetric(horizontal: 20),
                                      child: _confirmButton(userData, user,
                                          context, themeProvider),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }));
            } else {
              return Loading();
            }
          });
    } else {
      return Loading();
    }
  }

  callback(varLabel, varValue) {
    formField[varLabel] = varValue;
  }

  // CONFRIM PERSONAL INFO CHANGES
  Widget _confirmButton(UserData? userData, User user, BuildContext context,
      ThemeProvider themeProvider) {
    return ElevatedButton.icon(
      icon: Icon(
        CommunityMaterialIcons.account_edit_outline,
        color: Colors.white,
      ),
      label: Text(
        'Upravit údaje',
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
            formValues[2] ?? userData.spz,
            userData.stand,
            userData.card,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Změna osobních údajů proběhla úspěšně!'),
              duration: Duration(milliseconds: 1200),
            ),
          );
        }
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
}
