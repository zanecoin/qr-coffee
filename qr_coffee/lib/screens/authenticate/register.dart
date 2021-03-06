import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/service/auth.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();
  List formValues = [];
  bool loading = false;

  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = Responsive.deviceHeight(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.themeData().backgroundColor,
      appBar: customAppBar(context, title: Text('')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                AppStringValues.app_name,
                style: TextStyle(
                  color: themeProvider.themeAdditionalData().textColor,
                  fontSize: Responsive.width(12.0, context),
                  fontFamily: 'Galada',
                ),
              ),
              if (deviceHeight > kDeviceLowerHeightTreshold)
                ImageBanner(
                  path: themeProvider.isLightMode()
                      ? 'assets/cafe_transparent_black_border.png'
                      : 'assets/cafe_transparent_white_border.png',
                  size: 'medium',
                  color: themeProvider.themeAdditionalData().backgroundColor!,
                ),
              Container(
                width: Responsive.isLargeDevice(context) ? 400.0 : Responsive.width(70.0, context),
                child: Form(
                  key: _key,
                  child: Column(
                    children: [
                      SizedBox(height: Responsive.height(3.0, context)),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              AppStringValues.name,
                              Icons.person_outline,
                              _formCallback,
                              hasIcon: false,
                            ),
                          ),
                          SizedBox(width: 15.0),
                          Expanded(
                            child: CustomTextField(
                              AppStringValues.surname,
                              Icons.person,
                              _formCallback,
                              hasIcon: false,
                            ),
                          ),
                        ],
                      ),
                      CustomTextField(
                        AppStringValues.email,
                        Icons.mail_outline_sharp,
                        _formCallback,
                        validation: validateEmail,
                      ),
                      CustomTextField(
                        AppStringValues.password,
                        Icons.vpn_key,
                        _formCallback,
                        obscure: true,
                        validation: validatePassword,
                      ),
                      SizedBox(height: Responsive.height(1.0, context)),
                      CustomOutlinedButton(
                        function: _registerFunc,
                        label: AppStringValues.registration2,
                      ),
                      SizedBox(height: Responsive.height(2.0, context)),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (loading) Loading(delay: false)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _formCallback(varLabel, varValue) {
    formField[varLabel] = varValue;
  }

  // Register button function.
  _registerFunc() async {
    setState(() {
      loading = true;
      errorMessage = '';
      formValues = [];
    });
    FocusManager.instance.primaryFocus!.unfocus();

    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      formField.forEach((label, value) => formValues.add(value.trim()));

      String name = formValues[0];
      String surname = formValues[1];
      String email = formValues[2];
      String password = formValues[3];

      errorMessage = await _auth.registerWithEmailAndPassword(name, surname, email, password);

      if (errorMessage.length == 0) {
        Navigator.pop(context);
      } else {
        setState(() => loading = false);
      }
    } else {
      setState(() => loading = false);
    }
  }
}
