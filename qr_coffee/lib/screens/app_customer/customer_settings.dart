import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_customer/customer_update_form.dart';
import 'package:qr_coffee/service/auth.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class CustomerSettings extends StatefulWidget {
  @override
  _CustomerSettingsState createState() => _CustomerSettingsState();
}

class _CustomerSettingsState extends State<CustomerSettings> {
  late UserData userData;
  final AuthService _auth = AuthService();
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    // INITIALIZATION
    final user = Provider.of<User?>(context);

    if (user != null) {
      return StreamBuilder<UserData>(
        stream: UserDatabase(uid: user.uid).userData,
        builder: (context, snapshot1) {
          if (snapshot1.hasData) {
            userData = snapshot1.data!;

            return Scaffold(
              appBar: customAppBar(
                context,
                title: Text(CzechStrings.settings),
                type: 1,
              ),
              body: SingleChildScrollView(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomCircleAvatar(icon: Icons.person),
                        SizedBox(height: 20.0),
                        Text(
                          '${userData.name} ${userData.surname}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                        ),
                        SizedBox(height: 10.0),
                        CustomOutlinedIconButton(
                          function: _openEditing,
                          icon: CommunityMaterialIcons.account_edit_outline,
                          label: CzechStrings.editInfo,
                        ),
                        SizedBox(height: 10.0),
                        CustomOutlinedIconButton(
                          function: _auth.userSignOut,
                          icon: Icons.exit_to_app,
                          label: CzechStrings.logout,
                        ),
                        SizedBox(height: 10.0),
                        CustomDivider(indent: 30.0),
                        SizedBox(height: 5.0),
                        CustomOptionButton(
                          title: CzechStrings.role,
                          current: _extractUserRole(userData.role),
                          function: _updateUserRole,
                          options: [
                            CzechStrings.admin,
                            CzechStrings.worker,
                            CzechStrings.customer,
                          ],
                        ),
                        CustomOptionButton(
                          title: CzechStrings.mode,
                          current: CzechStrings.lightmode,
                          function: _callbackTheme,
                          options: [
                            CzechStrings.lightmode,
                            CzechStrings.darkmode,
                            CzechStrings.adaptToDevice,
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
  }

  void _callbackTheme(String result) {
    customSnackbar(context: context, text: CzechStrings.notImplemented);
  }

  void _openEditing() {
    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => CustomerUpdateForm(userData: userData)));
  }

  String _extractUserRole(String role) {
    String result = '';
    if (role == 'admin') {
      result = CzechStrings.admin;
    } else if (role == 'worker') {
      result = CzechStrings.worker;
    } else {
      result = CzechStrings.customer;
    }
    return result;
  }

  _updateUserRole(String result) {
    String role = '';
    if (result == CzechStrings.admin) {
      role = 'admin';
    } else if (result == CzechStrings.worker) {
      role = 'worker';
    } else {
      role = 'customer';
    }
    UserDatabase(uid: userData.uid).updateRole(role);
  }
}
