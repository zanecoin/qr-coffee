import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/screens/order_screens/order_details.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/image_banner.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/strings.dart';

// TILE WITH ORDER IN ORDER LIST
class OrderTile extends StatelessWidget {
  final Order order;
  final String time;
  final String role;

  OrderTile({
    required this.order,
    required this.role,
    this.time = '',
  });

  @override
  Widget build(BuildContext context) {
    String coffeeLabel;
    String remainingTime;
    Widget icon;
    Color color = Colors.black;

    // CZECH LANGUAGE FORMATTING
    if (order.items.length == 1) {
      coffeeLabel = order.items[0];
    } else if (order.items.length > 1 && order.items.length < 5) {
      coffeeLabel = '${order.items.length} položky';
    } else {
      coffeeLabel = '${order.items.length} položek';
    }

    // ICON CHOOSER
    if (order.status == 'ACTIVE' || order.status == 'READY') {
      icon = waitingIcon();
    } else if (order.status == 'ABANDONED') {
      icon = questionIcon();
    } else if (order.status == 'ABORTED') {
      icon = errorIcon();
    } else {
      icon = checkIcon(color: Colors.green.shade400);
    }

    // INFORMATION HEADER FORMAT CHOOSER
    if (order.status == 'ACTIVE' || order.status == 'READY') {
      List returnArray =
          time == '' ? ['?', Colors.black] : getRemainingTime(order, time);
      remainingTime = returnArray[0];
      color = returnArray[1];
    } else if (order.status == 'PENDING') {
      remainingTime = CzechStrings.orderPending;
    } else {
      remainingTime = '${timeFormatter(order.pickUpTime)}';
    }

    // THE WIDGET ITSELF
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => OrderDetails(
                  order: order,
                  role: role,
                  mode: 'normal',
                ),
              ),
            );
          },
          child: Container(
            height: Responsive.height(15, context),
            width: Responsive.width(67, context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: Offset(1, 1),
                  blurRadius: 15,
                  spreadRadius: 0,
                )
              ],
            ),
            child: Center(
              child: Row(
                children: [
                  SizedBox(width: Responsive.width(4, context)),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ImageBanner(
                        path: 'assets/cafe.jpg',
                        size: 'small',
                        color: Colors.white,
                      ),
                      if (role == 'worker-on')
                        Positioned(
                            child: icon, top: Responsive.height(4, context)),
                    ],
                  ),
                  SizedBox(width: Responsive.width(2, context)),
                  if (role == 'customer')
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$coffeeLabel',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${order.price} ${CzechStrings.currency}'),
                        Text(remainingTime, style: TextStyle(color: color)),
                        SizedBox(height: 5),
                        if (order.status == 'READY') _orderReady(),
                      ],
                    ),
                  if (role == 'worker-on')
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${order.username}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${coffeeLabel}'),
                        Text(remainingTime, style: TextStyle(color: color)),
                        SizedBox(height: 5),
                        if (order.status == 'READY') _orderReady(),
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

  Widget _orderReady() => Container(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(CzechStrings.orderReady),
      );
}
