import 'package:flutter/material.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/auth.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

String extractUserRole(String role) {
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

class SettingsButtons extends StatelessWidget {
  SettingsButtons({
    Key? key,
    required this.role,
    required this.generalContext,
    required this.userID,
  }) : super(key: key);

  final String role;
  final BuildContext generalContext;
  final String userID;
  late BuildContext thisContext;

  @override
  Widget build(BuildContext context) {
    thisContext = context;
    return Column(
      children: [
        SizedBox(height: 10.0),
        CustomOutlinedIconButton(
          function: _signOut,
          icon: Icons.exit_to_app,
          label: AppStringValues.logout,
          iconColor: Colors.blue,
        ),
        SizedBox(height: 10.0),
        CustomDivider(indent: 30.0),
        SizedBox(height: 5.0),
        CustomOptionButton(
          title: AppStringValues.role,
          current: extractUserRole(role),
          function: _updateUserRole,
          options: [
            AppStringValues.admin,
            AppStringValues.worker,
            AppStringValues.customer,
          ],
          generalContext: generalContext,
          previousRole: role,
          userID: userID,
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
          generalContext: generalContext,
          previousRole: role,
          userID: userID,
        ),
        SizedBox(height: 5.0),
        CustomDivider(indent: 30.0),
      ],
    );
  }

  void _signOut() {
    AuthService().userSignOut();
    if (role == 'customer') {
      Navigator.pop(thisContext);
    }
  }
}

_updateUserRole(String futureRole, String previousRole, BuildContext context, String userID) {
  String role = '';
  if (futureRole == AppStringValues.admin) {
    role = 'admin';
  } else if (futureRole == AppStringValues.worker) {
    role = 'worker';
  } else {
    role = 'customer';
  }
  if (previousRole == 'customer') {
    Navigator.pop(context);
  }

  UserData(userID: userID, role: '').updateRole(role);
}

// Empty Strings are there bcs it must match with parameters of [_updateUserRole()] bcs they are
// sent to same widget [CustomOptionButton()]
void _callbackTheme(String x, String y, BuildContext context, String z) {
  customSnackbar(context: context, text: AppStringValues.notImplemented);
}
