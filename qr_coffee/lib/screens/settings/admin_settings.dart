import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/models/admin.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_company/common/company_update_form.dart';
import 'package:qr_coffee/screens/settings/common_functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class AdminSettings extends StatefulWidget {
  @override
  _AdminSettingsState createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  bool darkMode = false;
  late Company company;

  @override
  Widget build(BuildContext context) {
    final userFromAuth = Provider.of<UserFromAuth?>(context);
    final admin = Provider.of<Admin>(context);
    company = Provider.of<Company>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (userFromAuth != null && company.phone != '') {
      return Scaffold(
        backgroundColor: themeProvider.themeData().backgroundColor,
        appBar: customAppBar(
          context,
          title: Text(AppStringValues.app_name,
              style: TextStyle(
                fontFamily: 'Galada',
                fontSize: 30,
                color: themeProvider.themeAdditionalData().textColor,
              )),
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
                  _adminInfoColumn(company),
                  SettingsButtons(
                    role: admin.role,
                    generalContext: context,
                    userID: admin.userID,
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

  void _openEditing() {
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => CompanyUpdateForm(company: company)));
  }

  Widget _adminInfoColumn(Company company) {
    return Column(
      children: [
        Text('ID: ${company.companyID}', style: TextStyle(color: Colors.grey)),
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
