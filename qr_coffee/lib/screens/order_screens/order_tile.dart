import 'dart:math';

import 'package:provider/provider.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details_customer.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details_worker.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/image_banner.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/strings.dart';

// TILE WITH ORDER IN ORDER LIST ---------------------------------------------------------------------------------------
class OrderTile extends StatelessWidget {
  final Order order;
  final String time;
  final UserRole role;

  OrderTile({
    required this.order,
    required this.role,
    this.time = '',
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    String coffeeLabel;
    String remainingTime;
    Widget icon;
    Color color = themeProvider.themeAdditionalData().textColor!;
    double iconSize = Responsive.height(4, context);

    // Czech language formatting.
    if (order.items.length == 1) {
      coffeeLabel = order.items.values.first;
    } else if (order.items.length > 1 && order.items.length < 5) {
      coffeeLabel = '${order.items.length} položky';
    } else {
      coffeeLabel = '${order.items.length} položek';
    }

    // Icon chooser.
    if (order.status == OrderStatus.waiting || order.status == OrderStatus.ready) {
      icon = waitingIcon(size: iconSize);
    } else if (order.status == OrderStatus.abandoned) {
      icon = questionIcon(size: iconSize);
    } else if (order.status == OrderStatus.aborted) {
      icon = errorIcon(size: iconSize);
    } else {
      icon = checkIcon(size: iconSize, color: Colors.green.shade400);
    }

    // Information header format chooser.
    if (order.status == OrderStatus.waiting || order.status == OrderStatus.ready) {
      List returnArray = time == '' ? ['?', color] : getRemainingTime(order, time, themeProvider);
      remainingTime = returnArray[0];
      color = returnArray[1];
    } else if (order.status == OrderStatus.pending) {
      remainingTime = AppStringValues.orderPending;
    } else {
      remainingTime = '${timeFormatter(order.pickUpTime)}';
    }

    // The widget itself.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Card(
        color: themeProvider.themeAdditionalData().containerColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: InkWell(
          onTap: () {
            if (role == UserRole.customer) {
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => OrderDetailsCustomer(order: order, mode: 'normal'),
                ),
              );
            } else {
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => OrderDetailsWorker(order: order, mode: 'normal'),
                ),
              );
            }
          },
          child: Container(
            height: max(Responsive.height(15, context), 90),
            width: Responsive.width(67, context),
            decoration: BoxDecoration(
              color: themeProvider.themeAdditionalData().containerColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: themeProvider.themeAdditionalData().shadow,
            ),
            child: Center(
              child: Row(
                children: [
                  SizedBox(width: Responsive.width(4, context)),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ImageBanner(
                          path: themeProvider.isLightMode()
                              ? 'assets/cafe.jpg'
                              : 'assets/cafe_darkmode.png',
                          size: 'small',
                          color: themeProvider.themeAdditionalData().containerColor!),
                      if (role == UserRole.worker)
                        Positioned(child: icon, top: Responsive.height(4.5, context)),
                    ],
                  ),
                  SizedBox(width: Responsive.width(2, context)),
                  if (role == UserRole.customer)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$coffeeLabel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: themeProvider.themeAdditionalData().textColor,
                            )),
                        Text('${order.price} ${AppStringValues.currency}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: themeProvider.themeAdditionalData().textColor,
                            )),
                        Text(remainingTime, style: TextStyle(color: color, fontSize: 11.0)),
                        SizedBox(height: 5),
                        if (order.status == OrderStatus.ready) _orderReady(themeProvider),
                      ],
                    ),
                  if (role == UserRole.worker)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cutTextIfNeccessary(
                              order.username, Responsive.textTresholdShort(context)),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeProvider.themeAdditionalData().textColor,
                          ),
                        ),
                        Text('${coffeeLabel}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: themeProvider.themeAdditionalData().textColor,
                            )),
                        Text(remainingTime, style: TextStyle(color: color, fontSize: 11.0)),
                        SizedBox(height: 5),
                        if (order.status == OrderStatus.ready) _orderReady(themeProvider),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderReady(ThemeProvider themeProvider) => Container(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: role == UserRole.customer
              ? themeProvider.themeAdditionalData().greenBannerColor
              : themeProvider.themeAdditionalData().blueBannerColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          AppStringValues.orderReady,
          style: TextStyle(
            color: themeProvider.themeAdditionalData().textColor,
          ),
        ),
      );
}
