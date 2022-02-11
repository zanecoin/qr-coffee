import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/widgets/custom_option_dialog.dart';

class CustomOptionButton extends StatelessWidget {
  const CustomOptionButton({
    Key? key,
    required this.title,
    required this.current,
    required this.function,
    required this.options,
  }) : super(key: key);

  final String title;
  final String current;
  final Function function;
  final List<String> options;

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
        onTap: () => customOptionDialog(context, function, options),
      ),
    );
  }
}
