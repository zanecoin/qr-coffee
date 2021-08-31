import 'package:cafe_app/shared/custom_text_field.dart';
import 'package:cafe_app/shared/image_banner.dart';
import 'package:flutter/material.dart';
import 'package:cafe_app/service/auth.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:cafe_app/shared/loading.dart';

class SignIn extends StatefulWidget {
  //switch between register and sign in
  final Function? toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();
  bool loading = false;
  List formValues = [];

  //user info variables
  String email = '';
  String password = '';
  String errorMessage = '';

  // sign in screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 22),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            }),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(
              app_name,
              style: TextStyle(
                  color: Colors.black, fontSize: 40, fontFamily: 'Galada'),
            ),
            ImageBanner(path: 'assets/cafe.jpg', size: 'medium'),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.width(15, context)),
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: Responsive.height(3, context)),
                    CustomTextField(
                        'E-mail', Icons.mail_outline_sharp, callback,
                        validation: validateEmail),
                    CustomTextField('Heslo', Icons.vpn_key, callback,
                        obscure: true, validation: validatePassword),
                    SizedBox(height: Responsive.height(1, context)),
                    Container(
                      height: Responsive.height(7, context),
                      margin: EdgeInsets.symmetric(
                          horizontal: Responsive.width(10, context)),
                      child: ElevatedButton(
                        child: loading
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Přihlásit se',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                        onPressed: () async {
                          setState(() {
                            loading = true;
                            errorMessage = '';
                            formValues = [];
                          });
                          if (_key.currentState!.validate()) {
                            FocusManager.instance.primaryFocus!.unfocus();
                            _key.currentState!.save();
                            formField.forEach(
                                (label, value) => formValues.add(value));
                            errorMessage =
                                await _auth.signInWithEmailAndPassword(
                                    formValues[0], formValues[1]);
                            if (errorMessage.length == 0) {
                              Navigator.pop(context);
                            } else {
                              setState(() => loading = false);
                            }
                          } else {
                            setState(() => loading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                      ),
                    ),
                    SizedBox(height: Responsive.height(2, context)),
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
                        'Zapomněli jste heslo?',
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
    );
  }

  callback(varLabel, varValue) {
    formField[varLabel] = varValue;
  }
}
