import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class CustomerUpdateForm extends StatefulWidget {
  const CustomerUpdateForm({Key? key, required this.userData}) : super(key: key);

  final UserData userData;

  @override
  _CustomerUpdateFormState createState() => _CustomerUpdateFormState(userData: userData);
}

class _CustomerUpdateFormState extends State<CustomerUpdateForm> {
  _CustomerUpdateFormState({required this.userData});
  final UserData userData;

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
                  _customerForm(),
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

  Widget _customerForm() {
    return Column(
      children: [
        CustomTextField(
          CzechStrings.name,
          Icons.person_outline,
          _callbackForm,
          initVal: userData.name,
          validation: validateName,
        ),
        CustomTextField(
          CzechStrings.surname,
          Icons.person,
          _callbackForm,
          initVal: userData.surname,
          validation: validateName,
        ),
      ],
    );
  }
}
