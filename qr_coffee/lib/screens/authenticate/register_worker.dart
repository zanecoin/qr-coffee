import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:qr_coffee/shared/widgets/custom_button_style.dart';
import 'package:qr_coffee/shared/widgets/custom_text_field.dart';
import 'package:qr_coffee/shared/widgets/image_banner.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/service/auth.dart';
import 'package:qr_coffee/shared/constants.dart';

class RegisterWorker extends StatefulWidget {
  //switch between register and sign in
  final Function? toggleView;
  RegisterWorker({this.toggleView});

  @override
  _RegisterWorkerState createState() => _RegisterWorkerState();
}

class _RegisterWorkerState extends State<RegisterWorker> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();
  List formValues = [];
  bool loading = false;

  //user info variables
  String name = '';
  String surname = '';
  String email = '';
  String password = '';
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context, title: Text(''), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(
              CzechStrings.app_name,
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
                    CustomTextField('Jméno', Icons.person_outline, callback),
                    CustomTextField('Příjmení', Icons.person, callback),
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
                                'Registrovat se',
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
                                await _auth.registerWithEmailAndPassword(
                                    formValues[0],
                                    formValues[1],
                                    formValues[2],
                                    formValues[3],
                                    'customer');
                            if (errorMessage.length == 0) {
                              Navigator.pop(context);
                            } else {
                              setState(() => loading = false);
                            }
                          } else {
                            setState(() => loading = false);
                          }
                        },
                        style: customButtonStyle(),
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
                        'Máte změstnanecké ID? Klikněte zde pro registraci jako zaměsnanec.',
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
