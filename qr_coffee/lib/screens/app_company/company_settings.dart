import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_company/company_update_form.dart';
import 'package:qr_coffee/service/auth.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class CompanySettings extends StatefulWidget {
  @override
  _CompanySettingsState createState() => _CompanySettingsState();
}

class _CompanySettingsState extends State<CompanySettings> {
  late UserData userData;
  late Company company;
  final AuthService _auth = AuthService();
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final double deviceWidth = Responsive.deviceWidth(context);

    if (user != null) {
      return StreamBuilder<UserData>(
        stream: UserDatabase(uid: user.uid).userData,
        builder: (context, snapshot1) {
          if (snapshot1.hasData) {
            userData = snapshot1.data!;

            return StreamBuilder<Company>(
              stream: CompanyDatabase(uid: userData.company).company,
              builder: (context, snapshot2) {
                if (snapshot2.hasData) {
                  company = snapshot2.data!;

                  return Scaffold(
                    appBar: customAppBar(
                      context,
                      title: Text(AppStringValues.app_name,
                          style: TextStyle(fontFamily: 'Galada', fontSize: 30)),
                      type: 3,
                    ),
                    body: SingleChildScrollView(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomCircleAvatar(icon: Icons.store),
                              SizedBox(height: 20.0),
                              Text(
                                company.name,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                              ),
                              if (userData.role == 'admin') _adminInfoColumn(company, deviceWidth),
                              SizedBox(height: 10.0),
                              CustomOutlinedIconButton(
                                function: _auth.userSignOut,
                                icon: Icons.exit_to_app,
                                label: AppStringValues.logout,
                                iconColor: Colors.blue,
                              ),
                              SizedBox(height: 10.0),
                              CustomDivider(indent: 30.0),
                              SizedBox(height: 5.0),
                              if (userData.switching)
                                CustomOptionButton(
                                  title: AppStringValues.role,
                                  current: _extractUserRole(userData.role),
                                  function: _updateUserRole,
                                  options: [
                                    AppStringValues.admin,
                                    AppStringValues.worker,
                                    AppStringValues.customer,
                                  ],
                                ),
                              CustomOptionButton(
                                title: AppStringValues.mode,
                                current: AppStringValues.lightmode,
                                function: _callbackTheme,
                                options: [
                                  AppStringValues.lightmode,
                                  AppStringValues.darkmode,
                                  AppStringValues.adaptToDevice,
                                ],
                              ),
                              SizedBox(height: 5.0),
                              CustomDivider(indent: 30.0),
                            ],
                          ),
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
        },
      );
    } else {
      return Loading();
    }
  }

  void _callbackTheme(String result) {
    customSnackbar(context: context, text: AppStringValues.notImplemented);
  }

  void _openEditing() {
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => CompanyUpdateForm(company: company)));
  }

  String _extractUserRole(String role) {
    String result = '';
    if (role == 'admin') {
      result = AppStringValues.admin;
    } else if (role == 'worker') {
      result = AppStringValues.worker;
    } else {
      result = AppStringValues.customer;
    }
    return result;
  }

  _updateUserRole(String result) {
    String role = '';
    if (result == AppStringValues.admin) {
      role = 'admin';
    } else if (result == AppStringValues.worker) {
      role = 'worker';
    } else {
      role = 'customer';
    }
    if (userData.role == 'customer') {
      Navigator.pop(context);
    }
    UserDatabase(uid: userData.uid).updateRole(role);
  }

  Widget _adminInfoColumn(Company company, double deviceWidth) {
    return Column(
      children: [
        Text('ID: ${company.uid}', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 20.0),
        CustomTextBanner(
          title: company.email,
          icon: Icons.email_outlined,
        ),
        SizedBox(height: 10.0),
        CustomTextBanner(
            title: '${company.phone.substring(4, 7)} '
                '${company.phone.substring(7, 10)} '
                '${company.phone.substring(10)}',
            icon: Icons.phone_iphone_outlined),
        SizedBox(height: 10.0),
        CustomTextBanner(
          title: '${AppStringValues.shopNum}: ${company.numShops}',
          icon: Icons.store,
        ),
        SizedBox(height: 15.0),
        CustomOutlinedIconButton(
          function: _openEditing,
          icon: CommunityMaterialIcons.file_edit_outline,
          label: AppStringValues.editInfo,
          iconColor: Colors.blue,
        ),
      ],
    );
  }
}