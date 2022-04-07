import 'package:flutter/material.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/auth.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

String extractUserRole(UserRole role) {
  String result = '';
  if (role == UserRole.admin) {
    result = AppStringValues.admin;
  } else if (role == UserRole.worker) {
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

  final UserRole role;
  final BuildContext generalContext;
  final String userID;
  late BuildContext thisContext;

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = Responsive.deviceWidth(context);
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
        CustomDivider(
            indent:
                deviceWidth > kDeviceUpperWidthTreshold ? Responsive.width(20.0, context) : 30.0),
        SizedBox(height: 2.0),
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
        SizedBox(height: 2.0),
        CustomDivider(
            indent:
                deviceWidth > kDeviceUpperWidthTreshold ? Responsive.width(20.0, context) : 30.0),
      ],
    );
  }

  void _signOut() {
    AuthService().userSignOut();
    if (role == UserRole.customer) {
      Navigator.pop(thisContext);
    }
  }
}

_updateUserRole(String futureRole, UserRole previousRole, BuildContext context, String userID) {
  UserRole role;
  if (futureRole == AppStringValues.admin) {
    role = UserRole.admin;
  } else if (futureRole == AppStringValues.worker) {
    role = UserRole.worker;
  } else {
    role = UserRole.customer;
  }
  if (previousRole == UserRole.customer) {
    Navigator.pop(context);
  }

  UserData(userID: userID, role: UserRole.customer).updateRole(role);
}

// Empty Strings are there bcs it must match with parameters of [_updateUserRole()] bcs they are
// sent to same widget [CustomOptionButton()]
void _callbackTheme(String x, String y, BuildContext context, String z) {
  customSnackbar(context: context, text: AppStringValues.notImplemented);
}
