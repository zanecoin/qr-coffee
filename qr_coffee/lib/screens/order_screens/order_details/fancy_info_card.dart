import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

class FancyInfoCard extends StatelessWidget {
  const FancyInfoCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      width: Responsive.isLargeDevice(context) ? Responsive.width(50, context) : null,
      decoration: BoxDecoration(
        color: themeProvider.themeAdditionalData().containerColor,
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
        boxShadow: themeProvider.themeAdditionalData().shadow,
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    image: DecorationImage(
                      colorFilter:
                          new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                      image: AssetImage(
                        themeProvider.isLightMode()
                            ? 'assets/cafe.jpg'
                            : 'assets/cafe_darkmode.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  Responsive.isLargeDevice(context)
                      ? (cutTextIfNeccessary(order.username, 400 ~/ 17))
                      : (cutTextIfNeccessary(
                          order.username, Responsive.textTresholdShort(context))),
                  style: TextStyle(
                    fontSize: 23,
                    color: themeProvider.themeAdditionalData().textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${order.price.toString()} ${AppStringValues.currency}',
                  style: TextStyle(
                    fontSize: 30,
                    color: themeProvider.themeAdditionalData().textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '${AppStringValues.orderCode}: ${order.orderID.substring(0, 6).toUpperCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.themeAdditionalData().textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
