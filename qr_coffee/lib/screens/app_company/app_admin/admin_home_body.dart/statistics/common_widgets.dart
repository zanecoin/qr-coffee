import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

class ChartHeader extends StatelessWidget {
  ChartHeader({
    Key? key,
    required this.text,
    required this.callback,
    required this.showMoney,
  }) : super(key: key);

  Text text;
  Function callback;
  bool showMoney;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      height: 50,
      decoration: BoxDecoration(
        color: themeProvider.isLightMode() ? Colors.grey.shade100 : Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
            child: TextButton.icon(
              onPressed: () => callback(),
              label: Text(
                showMoney ? 'Tržba' : 'Počet',
                style: TextStyle(
                  color: themeProvider.themeAdditionalData().textColor,
                  fontSize: 10.0,
                ),
              ),
              icon: Icon(
                Icons.analytics,
                size: 15,
                color: themeProvider.themeAdditionalData().textColor,
              ),
              style: TextButton.styleFrom(
                backgroundColor: themeProvider.themeAdditionalData().FlBorderColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
            ),
          ),
          VerticalDivider(
            thickness: 1.0,
            indent: 15.0,
            endIndent: 15.0,
            color: themeProvider.themeAdditionalData().unselectedColor,
          ),
          text,
        ],
      ),
    );
  }
}
