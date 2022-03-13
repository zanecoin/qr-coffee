import 'package:flutter/material.dart';

Future<dynamic> customOptionDialog(
  Function function,
  List<String> options,
  BuildContext context,
  BuildContext generalContext,
  String previousRole,
  String userID,
) {
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
              _textButton(function, context, generalContext, options[0], previousRole, userID),
              _textButton(function, context, generalContext, options[1], previousRole, userID),
              _textButton(function, context, generalContext, options[2], previousRole, userID),
            ],
          ),
        ),
      );
    },
  );
}

Widget _textButton(
  Function function,
  BuildContext context,
  BuildContext generalContext,
  String futureRole,
  String previousRole,
  String userID,
) {
  return TextButton(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      primary: Colors.black,
      backgroundColor: Colors.white,
    ),
    child: Text(futureRole, style: TextStyle(fontSize: 16)),
    onPressed: () {
      function(futureRole, previousRole, generalContext, userID);
      Navigator.pop(context);
    },
  );
}
