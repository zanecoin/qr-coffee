import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/widgets/custom_option_dialog.dart';

class CustomOptionButton extends StatelessWidget {
  const CustomOptionButton({
    Key? key,
    required this.title,
    required this.current,
    required this.function,
    required this.options,
    required this.generalContext,
    required this.previousRole,
    required this.userID,
  }) : super(key: key);

  final String title;
  final String current;
  final Function function;
  final List<String> options;
  final BuildContext generalContext;
  final String previousRole;
  final String userID;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.0),
      child: InkWell(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 16.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    current,
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  Icon(Icons.arrow_forward_ios),
                ],
              )
            ],
          ),
        ),
        onTap: () =>
            customOptionDialog(function, options, context, generalContext, previousRole, userID),
      ),
    );
  }
}
