import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
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
    FocusManager.instance.primaryFocus!.unfocus();

    if (_key.currentState!.validate()) {
      _key.currentState!.save();

      String name = (formField[AppStringValues.name] ?? userData.name);
      String surname = (formField[AppStringValues.surname] ?? userData.surname);

      try {
        await UserDatabase(uid: userData.uid).updateName(name, surname);
        Navigator.pop(context);
        customSnackbar(context: context, text: AppStringValues.infoChangeSuccess);
      } catch (e) {
        customSnackbar(context: context, text: e.toString());
      }
    }
  }

  Widget _customerForm() {
    return Column(
      children: [
        CustomTextField(
          AppStringValues.name,
          Icons.person_outline,
          _callbackForm,
          initVal: userData.name,
          validation: validateName,
        ),
        CustomTextField(
          AppStringValues.surname,
          Icons.person,
          _callbackForm,
          initVal: userData.surname,
          validation: validateName,
        ),
      ],
    );
  }
}
