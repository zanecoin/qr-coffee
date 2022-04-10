import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/customer.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class CustomerUpdateForm extends StatefulWidget {
  const CustomerUpdateForm({Key? key, required this.customer}) : super(key: key);

  final Customer customer;

  @override
  _CustomerUpdateFormState createState() => _CustomerUpdateFormState(customer: customer);
}

class _CustomerUpdateFormState extends State<CustomerUpdateForm> {
  _CustomerUpdateFormState({required this.customer});
  final Customer customer;

  final _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.themeData().backgroundColor,
      appBar: customAppBar(context, title: Text(''), type: 1),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            width: Responsive.isLargeDevice(context) ? Responsive.width(60, context) : null,
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

      String name = (formField[AppStringValues.name] ?? customer.name);
      String surname = (formField[AppStringValues.surname] ?? customer.surname);

      try {
        customer.updateName(name, surname);
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
          initVal: customer.name,
          validation: validateName,
        ),
        CustomTextField(
          AppStringValues.surname,
          Icons.person,
          _callbackForm,
          initVal: customer.surname,
          validation: validateName,
        ),
      ],
    );
  }
}
