import 'package:flutter/material.dart';

Future<dynamic> customOptionDialog(BuildContext context, Function function, List<String> options) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: <Widget>[
              _textButton(function, options[0], context),
              _textButton(function, options[1], context),
              _textButton(function, options[2], context),
            ],
          ),
        ),
      );
    },
  );
}

Widget _textButton(Function function, String option, BuildContext context) {
  return TextButton(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      primary: Colors.black,
      backgroundColor: Colors.white,
    ),
    child: Text(option, style: TextStyle(fontSize: 16)),
    onPressed: () {
      function(option);
      Navigator.pop(context);
    },
  );
}
