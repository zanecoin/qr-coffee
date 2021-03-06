import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
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
  final UserRole previousRole;
  final String userID;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: Responsive.isLargeDevice(context) ? Responsive.width(60.0, context) : null,
      margin: EdgeInsets.symmetric(horizontal: 30.0),
      child: InkWell(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  color: themeProvider.themeAdditionalData().textColor,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    current,
                    style: TextStyle(
                        fontSize: 12.0,
                        color: themeProvider.themeAdditionalData().blendedInvertColor),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: themeProvider.themeAdditionalData().textColor),
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
