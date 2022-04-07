import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/models/customer.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_customer/customer_update_form.dart';
import 'package:qr_coffee/screens/settings/common_functions.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class CustomerSettings extends StatefulWidget {
  @override
  _CustomerSettingsState createState() => _CustomerSettingsState();
}

class _CustomerSettingsState extends State<CustomerSettings> {
  bool darkMode = false;
  late Customer customer;

  @override
  Widget build(BuildContext context) {
    final userFromAuth = Provider.of<UserFromAuth?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (userFromAuth != null) {
      return StreamBuilder<Customer>(
        stream: CustomerDatabase(userID: userFromAuth.userID).customer,
        builder: (context, snapshot1) {
          if (snapshot1.hasData) {
            customer = snapshot1.data!;

            return Scaffold(
              backgroundColor: themeProvider.themeData().backgroundColor,
              appBar: customAppBar(context,
                  title: Text(
                    AppStringValues.settings,
                    style: TextStyle(
                      color: themeProvider.themeAdditionalData().textColor,
                    ),
                  ),
                  type: 1),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                            color: themeProvider.themeAdditionalData().textColor,
                          ),
                        ),
                        SizedBox(height: 15.0),
                        CustomOutlinedIconButton(
                          function: _openEditing,
                          icon: CommunityMaterialIcons.account_edit_outline,
                          label: AppStringValues.editInfo,
                          iconColor: Colors.blue,
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

  void _openEditing() {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => CustomerUpdateForm(
                  customer: customer,
                )));
  }
}
