import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/service/auth.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();
  bool loading = false;
  List formValues = [];

  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
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
                      CustomOutlinedButton(function: _signInFunc, label: AppStringValues.login2),
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () =>
                            customSnackbar(context: context, text: AppStringValues.notImplemented),
                        child: Text(
                          AppStringValues.forgotPassword,
                          textAlign: TextAlign.center,
                        ),
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

  // Sign in button function.
  _signInFunc() async {
    setState(() {
      loading = true;
      errorMessage = '';
      formValues = [];
    });
    FocusManager.instance.primaryFocus!.unfocus();

    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      formField.forEach((label, value) => formValues.add(value.trim()));

      String email = formValues[0];
      String password = formValues[1];

      errorMessage = await _auth.signInWithEmailAndPassword(email, password);

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
