import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

class CustomTimeDropdown extends StatefulWidget {
  CustomTimeDropdown({
    this.initVal = '',
    required this.label,
    required this.values,
    required this.callback,
  });

  final String initVal;
  final String label;
  final List<String> values;
  final Function callback;

  @override
  State<CustomTimeDropdown> createState() => _CustomTimeDropdownState(
        initVal: initVal,
        label: label,
        values: values,
        callback: callback,
      );
}

class _CustomTimeDropdownState extends State<CustomTimeDropdown> {
  _CustomTimeDropdownState({
    required this.initVal,
    required this.label,
    required this.values,
    required this.callback,
  });

  final String initVal;
  final String label;
  final List<String> values;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String? currentValue;
    return Container(
      height: 50,
      width: 110,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: themeProvider.themeAdditionalData().FlBorderColor!),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                value: currentValue,
                style:
                    TextStyle(color: themeProvider.themeAdditionalData().textColor, fontSize: 13.0),
                items: values.map((value) {
                  return DropdownMenuItem(
                    child: Text(value,
                        style: TextStyle(
                            color: themeProvider.themeAdditionalData().textColor, fontSize: 13.0)),
                    value: value,
                  );
                }).toList(),
                onChanged: (val) {
                  currentValue = val.toString();
                  callback(label, val);
                },
                dropdownColor: themeProvider.themeAdditionalData().buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
