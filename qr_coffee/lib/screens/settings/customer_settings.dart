import 'package:qr_coffee/models/customer.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/settings/common_functions.dart';
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
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    final userFromAuth = Provider.of<UserFromAuth?>(context);

    if (userFromAuth != null) {
      return StreamBuilder<Customer>(
        stream: CustomerDatabase(userID: userFromAuth.userID).customer,
        builder: (context, snapshot1) {
          if (snapshot1.hasData) {
            Customer customer = snapshot1.data!;

            return Scaffold(
              appBar: customAppBar(context, title: Text(AppStringValues.settings), type: 1),
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
                          '${customer.name} ${customer.surname}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                        ),
                        SettingsButtons(
                          role: customer.role,
                          generalContext: context,
                          userID: customer.userID,
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
        },
      );
    } else {
      return Loading();
    }
  }
}
