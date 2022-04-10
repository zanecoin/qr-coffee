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

  OrderTile({required this.order, required this.role, this.time = ''});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    String coffeeLabel;
    String remainingTime;
    Widget icon;
    Color color = _getTextColor(themeProvider);
    double iconSize = Responsive.height(4.0, context);

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
    } else if (order.status == OrderStatus.withdraw) {
      icon = fireIcon(size: iconSize);
    } else if (order.status == OrderStatus.abandoned) {
      icon = questionIcon(size: iconSize);
    } else if (order.status == OrderStatus.aborted) {
      icon = errorIcon(size: iconSize);
    } else {
      icon = checkIcon(size: iconSize, color: Colors.green.shade400);
    }

    // Information header format chooser.
    if (order.status == OrderStatus.waiting ||
        order.status == OrderStatus.ready ||
        order.status == OrderStatus.withdraw) {
      List returnArray =
          time == '' ? ['?', color] : getRemainingTime(order, time, themeProvider, true);
      remainingTime = returnArray[0];
      color = returnArray[1];
    } else if (order.status == OrderStatus.pending) {
      remainingTime = AppStringValues.orderPending;
    } else {
      remainingTime = '${timeFormatter(order.pickUpTime)}';
    }

    // The widget itself.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: Card(
        color: themeProvider.themeAdditionalData().containerColor,
        elevation: 0.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
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
            height: max(Responsive.height(15.0, context), 90.0),
            width: Responsive.width(67.0, context),
            decoration: BoxDecoration(
              gradient: _getGradient(themeProvider),
              color: order.status == OrderStatus.withdraw
                  ? null
                  : themeProvider.themeAdditionalData().containerColor,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: _getShadow(themeProvider),
            ),
            child: Center(
              child: Row(
                children: [
                  SizedBox(width: Responsive.width(4.0, context)),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ImageBanner(
                          path: _getImagePath(themeProvider),
                          size: 'small',
                          color:
                              themeProvider.themeAdditionalData().containerColor!.withOpacity(0.0)),
                      if (role == UserRole.worker)
                        Positioned(child: icon, top: Responsive.height(4.5, context)),
                    ],
                  ),
                  SizedBox(width: Responsive.width(2.0, context)),
                  if (role == UserRole.customer)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$coffeeLabel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(themeProvider),
                            )),
                        Text('${order.price} ${AppStringValues.currency}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(themeProvider),
                            )),
                        Text(remainingTime, style: TextStyle(color: color, fontSize: 11.0)),
                        const SizedBox(height: 5.0),
                        if (order.status == OrderStatus.ready) _orderReady(themeProvider),
                        if (order.status == OrderStatus.withdraw) _orderWithdraw(themeProvider),
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
                            color: _getTextColor(themeProvider),
                          ),
                        ),
                        Text('${coffeeLabel}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getTextColor(themeProvider),
                            )),
                        Text(remainingTime, style: TextStyle(color: color, fontSize: 11.0)),
                        const SizedBox(height: 5.0),
                        if (order.status == OrderStatus.ready) _orderReady(themeProvider),
                        if (order.status == OrderStatus.withdraw) _orderWithdraw(themeProvider),
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

  List<BoxShadow> _getShadow(ThemeProvider themeProvider) {
    if (order.status == OrderStatus.withdraw && themeProvider.isLightMode()) {
      return [
        BoxShadow(
          color: Colors.grey.shade300,
          offset: Offset(10.0, 10.0),
          blurRadius: 15.0,
          spreadRadius: 0.0,
        )
      ];
    } else {
      return themeProvider.themeAdditionalData().shadow!;
    }
  }

  LinearGradient? _getGradient(ThemeProvider themeProvider) {
    if (order.status == OrderStatus.withdraw) {
      return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeProvider.isLightMode() ? kGold : kSilver,
          stops: [0.1, 0.3, 0.8, 1]);
    } else {
      return null;
    }
  }

  String _getImagePath(ThemeProvider themeProvider) {
    if (!themeProvider.isLightMode() && order.status != OrderStatus.withdraw) {
      return 'assets/cafe_transparent_white_border.png';
    } else {
      return 'assets/cafe_transparent_black_border.png';
    }
  }

  Color _getTextColor(ThemeProvider themeProvider) {
    if (order.status == OrderStatus.withdraw) {
      if (themeProvider.isLightMode()) {
        return Color.fromARGB(255, 148, 101, 0);
      } else {
        return Color.fromARGB(255, 60, 60, 70);
      }
    } else {
      return themeProvider.themeAdditionalData().textColor!;
    }
  }

  Widget _orderReady(ThemeProvider themeProvider) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: role == UserRole.customer
              ? themeProvider.themeAdditionalData().greenBannerColor
              : themeProvider.themeAdditionalData().blueBannerColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          AppStringValues.orderReady,
          style: TextStyle(color: themeProvider.themeAdditionalData().textColor),
        ),
      );

  Widget _orderWithdraw(ThemeProvider themeProvider) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: themeProvider.isLightMode() ? kLightGold : kLightSilver,
              stops: [0.1, 0.3, 0.8, 1]),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: themeProvider.isLightMode() ? Colors.amber.shade600 : Colors.grey.shade600,
              offset: Offset(2.0, 2.0),
              blurRadius: 0.5,
              spreadRadius: 0.0,
            ),
          ],
        ),
        child: Text(
          AppStringValues.withdrawOngoing,
          style: TextStyle(
            color: themeProvider.isLightMode()
                ? Color.fromARGB(255, 148, 101, 0)
                : Color.fromARGB(255, 60, 60, 70),
          ),
        ),
      );
}
