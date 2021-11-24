import 'package:qr_coffee/shared/constants.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String initVal;
  final bool obscure;
  final String? Function(String?) validation;
  final Function callback;

  CustomTextField(this.label, this.icon, this.callback,
      {this.initVal = '',
      this.obscure = false,
      this.validation = validateText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Responsive.height(9, context),
      child: TextFormField(
        initialValue: initVal,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(
            icon,
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.green, width: 2.0),
          ),
        ),
        obscureText: validation == validatePassword,
        validator: validation,
        onSaved: (String? val) => callback(label, val),
      ),
    );
  }
}

String? noValidation(String? formText) {
  return null;
}

String? validateText(String? formText) {
  if (formText!.isEmpty) return 'Zadejte jméno.';

  return null;
}

String? validateEmail(String? formEmail) {
  if (formEmail!.isEmpty) return 'Zadejte e-mail.';

  String pattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail))
    return 'E-mailová adresa je v neplatném formátu.';

  return null;
}

String? validatePassword(String? formPassword) {
  if (formPassword!.isEmpty) return 'Zadejte heslo.';

  if (formPassword.length < 8) return 'Heslo musí mít minimálně 8 znaků.';

  return null;
}
