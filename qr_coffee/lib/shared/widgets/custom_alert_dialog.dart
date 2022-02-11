import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';

Future<dynamic> customAlertDialog(BuildContext context, Function function,
    {String title = CzechStrings.question}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 110,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      color: Colors.white,
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      primary: Colors.black,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    child: Text(CzechStrings.yes, style: TextStyle(fontSize: 14)),
                    onPressed: () {
                      function();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      primary: Colors.black,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    child: Text(CzechStrings.no, style: TextStyle(fontSize: 14)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
