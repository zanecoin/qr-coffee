import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:qr_coffee/shared/widgets/custom_button_style(depricated).dart';
import 'package:qr_coffee/shared/widgets/custom_text_field.dart';
import 'package:qr_coffee/shared/widgets/image_banner.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/service/auth.dart';
import 'package:qr_coffee/shared/constants.dart';

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

  String email = '';
  String password = '';
  String errorMessage = '';

  // Sign in screen.
  @override
  Widget build(BuildContext context) {
    double deviceWidth = Responsive.deviceWidth(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context, title: Text(''), elevation: 0),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Text(
                CzechStrings.app_name,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: Responsive.width(12, context),
                  fontFamily: 'Galada',
                ),
              ),
              ImageBanner(path: 'assets/cafe.jpg', size: 'medium'),
              Container(
                width:
                    deviceWidth > kDeviceUpperWidthTreshold ? 400 : Responsive.width(70, context),
                child: Form(
                  key: _key,
                  child: Column(
                    children: [
                      SizedBox(height: Responsive.height(3, context)),
                      CustomTextField(
                        CzechStrings.email,
                        Icons.mail_outline_sharp,
                        callback,
                        validation: validateEmail,
                      ),
                      CustomTextField(
                        CzechStrings.password,
                        Icons.vpn_key,
                        callback,
                        obscure: true,
                        validation: validatePassword,
                      ),
                      SizedBox(height: Responsive.height(1, context)),
                      Container(
                        width: Responsive.width(60, context),
                        child: ElevatedButton(
                          child: loading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  CzechStrings.login2,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                          onPressed: signIn,
                          style: customButtonStyle(),
                        ),
                      ),
                      //SizedBox(height: Responsive.height(2, context)),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          CzechStrings.forgotPassword,
                          textAlign: TextAlign.center,
                        ),
                      ),
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

  // TextFormField callback function.
  callback(varLabel, varValue) {
    formField[varLabel] = varValue;
  }

  // Sign in button function.
  signIn() async {
    setState(() {
      loading = true;
      errorMessage = '';
      formValues = [];
    });
    FocusManager.instance.primaryFocus!.unfocus();

    if (_key.currentState!.validate()) {
      _key.currentState!.save();
      formField.forEach((label, value) => formValues.add(value.trim()));

      email = formValues[0];
      password = formValues[1];
      print(email);
      print(password);

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
