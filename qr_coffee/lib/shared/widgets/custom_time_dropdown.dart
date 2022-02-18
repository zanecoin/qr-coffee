import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/constants.dart';

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
    final double deviceWidth = Responsive.deviceWidth(context);
    String? currentValue;
    return Container(
      //margin: EdgeInsets.symmetric(horizontal: 20),
      //width: deviceWidth > kDeviceUpperWidthTreshold ? Responsive.width(10, context) : null,
      height: 50,
      width: 110,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                value: currentValue,
                items: values.map((value) {
                  return DropdownMenuItem(
                    child: Text(value),
                    value: value,
                  );
                }).toList(),
                onChanged: (val) {
                  currentValue = val.toString();
                  callback(label, val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
