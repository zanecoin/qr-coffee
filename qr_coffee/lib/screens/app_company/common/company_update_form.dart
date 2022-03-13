import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class CompanyUpdateForm extends StatefulWidget {
  const CompanyUpdateForm({Key? key, required this.company}) : super(key: key);

  final Company company;

  @override
  _CompanyUpdateFormState createState() => _CompanyUpdateFormState(company: company);
}

class _CompanyUpdateFormState extends State<CompanyUpdateForm> {
  _CompanyUpdateFormState({required this.company});
  final Company company;

  final _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();
  List formValues = [];

  String name = '';
  String email = '';
  String phone = '';

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = Responsive.deviceWidth(context);
    return Scaffold(
      appBar: customAppBar(context, title: Text(''), type: 1),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            width: deviceWidth > kDeviceUpperWidthTreshold ? Responsive.width(60, context) : null,
            child: Form(
              key: _key,
              child: Column(
                children: <Widget>[
                  _companyForm(),
                  SizedBox(height: 10),
                  CustomOutlinedIconButton(
                    function: _updateValues,
                    icon: CommunityMaterialIcons.file_edit_outline,
                    label: AppStringValues.editInfo,
                    iconColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _callbackForm(varLabel, varValue) {
    formField[varLabel] = varValue;
  }

  _updateValues() async {
    setState(() {
      formValues = [];
    });

    FocusManager.instance.primaryFocus!.unfocus();

    if (_key.currentState!.validate()) {
      _key.currentState!.save();

      name = (formField[AppStringValues.name] ?? company.name).trim();
      email = (formField[AppStringValues.email] ?? company.email).trim();
      phone = '+420${(formField[AppStringValues.phone] ?? company.phone).trim()}';

      try {
        await CompanyDatabase(companyID: company.companyID).updateCompanyData(name, phone, email);
        Navigator.pop(context);
        customSnackbar(context: context, text: AppStringValues.companyInfoChangeSuccess);
      } catch (e) {
        customSnackbar(context: context, text: e.toString());
      }
    }
  }

  Widget _companyForm() {
    return Column(
      children: [
        CustomTextField(
          AppStringValues.name,
          Icons.store,
          _callbackForm,
          initVal: company.name,
          validation: validateName,
        ),
        CustomTextField(
          AppStringValues.email,
          Icons.email_outlined,
          _callbackForm,
          initVal: company.email,
          validation: validateEmail,
        ),
        CustomTextField(
          AppStringValues.phone,
          Icons.phone_android_outlined,
          _callbackForm,
          initVal: company.phone.substring(4),
          validation: validatePhone,
        ),
      ],
    );
  }
}
