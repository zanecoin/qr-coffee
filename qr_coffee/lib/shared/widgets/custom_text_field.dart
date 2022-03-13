import 'package:qr_coffee/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/strings.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField(
    this.label,
    this.icon,
    this.callback, {
    this.initVal = '',
    this.obscure = false,
    this.validation = validateName,
    this.hasIcon = true,
  });

  final String label;
  final IconData icon;
  final String initVal;
  final bool obscure;
  final String? Function(String?) validation;
  final Function callback;
  final bool hasIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: Responsive.height(1, context)),
      child: TextFormField(
        initialValue: initVal,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: hasIcon ? Icon(icon) : null,
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

String? validateName(String? formText) {
  if (formText!.isEmpty) return AppStringValues.enterName;
  return null;
}

String? validatePhone(String? formText) {
  if (formText!.isEmpty) return AppStringValues.enterPhone;
  return null;
}

String? validateAddress(String? formText) {
  if (formText!.isEmpty) return AppStringValues.enterAddress;
  return null;
}

String? validateCity(String? formText) {
  if (formText!.isEmpty) return AppStringValues.enterCity;
  return null;
}

String? validateEmail(String? formEmail) {
  if (formEmail!.isEmpty) return AppStringValues.enterEmail;

  String pattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail)) return AppStringValues.emailHasBadFormat;
  return null;
}

String? validatePassword(String? formPassword) {
  if (formPassword!.isEmpty) return AppStringValues.enterPassword;
  if (formPassword.length < 8) return AppStringValues.passwordAtLeastEightChar;
  return null;
}
