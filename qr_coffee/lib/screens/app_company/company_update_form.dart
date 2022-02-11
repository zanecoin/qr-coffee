import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/models/company.dart';
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
                    function: () {},
                    icon: CommunityMaterialIcons.file_edit_outline,
                    label: CzechStrings.editInfo,
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

  _updateValues() {
    setState(() {
      formValues = [];
    });

    if (_key.currentState!.validate()) {
      FocusManager.instance.primaryFocus!.unfocus();
      _key.currentState!.save();
      formField.forEach((label, value) => formValues.add(value.trim()));
      FocusManager.instance.primaryFocus!.unfocus();
      // await UserDatabase(uid: user.uid).updateName(
      //   formValues[0] ?? userData!.name,
      //   formValues[1] ?? userData!.surname,
      // );

      customSnackbar(context: context, text: CzechStrings.infoChangeSuccess);
    }
  }

  Widget _companyForm() {
    return Column(
      children: [
        CustomTextField(
          CzechStrings.name,
          Icons.store,
          _callbackForm,
          initVal: company.name,
          validation: validateName,
        ),
        CustomTextField(
          CzechStrings.email,
          Icons.email_outlined,
          _callbackForm,
          initVal: company.email,
          validation: validateEmail,
        ),
        CustomTextField(
          CzechStrings.phone,
          Icons.phone_android_outlined,
          _callbackForm,
          initVal: company.phone.substring(4),
          validation: validatePhone,
        ),
      ],
    );
  }
}
