import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/models/worker.dart';
import 'package:qr_coffee/screens/settings/common_functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class WorkerSettings extends StatefulWidget {
  @override
  _WorkerSettingsState createState() => _WorkerSettingsState();
}

class _WorkerSettingsState extends State<WorkerSettings> {
  @override
  Widget build(BuildContext context) {
    final userFromAuth = Provider.of<UserFromAuth?>(context);
    final worker = Provider.of<Worker>(context);
    final company = Provider.of<Company>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (userFromAuth != null) {
      return Scaffold(
        backgroundColor: themeProvider.themeData().backgroundColor,
        appBar: customAppBar(
          context,
          title: Text(
            AppStringValues.app_name,
            style: TextStyle(
              fontFamily: 'Galada',
              fontSize: 30,
              color: themeProvider.themeAdditionalData().textColor,
            ),
          ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      color: themeProvider.themeAdditionalData().textColor,
                    ),
                  ),
                  SettingsButtons(
                    role: worker.role,
                    generalContext: context,
                    userID: worker.userID,
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
  }
}
