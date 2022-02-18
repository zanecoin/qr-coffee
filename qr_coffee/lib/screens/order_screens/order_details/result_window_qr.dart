import 'package:flutter/material.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ResultWindow extends StatelessWidget {
  const ResultWindow({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    this.fontSize = 20.0,
  }) : super(key: key);

  final double fontSize;
  final String text;
  final Widget icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.0,
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 5.0),
            Text(text, style: TextStyle(fontSize: fontSize)),
          ],
        ),
      ),
    );
  }
}

class ResultWindowChooser extends StatelessWidget {
  const ResultWindowChooser({
    Key? key,
    required this.order,
    required this.mode,
    required this.role,
  }) : super(key: key);

  final Order order;
  final String mode;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (order.status == 'COMPLETED')
          ResultWindow(
            text: AppStringValues.orderCollected,
            color: Colors.green.shade100,
            icon: checkIcon(color: Colors.green.shade400),
          ),
        if (order.status == 'ABANDONED')
          ResultWindow(
            text: AppStringValues.orderAbandoned,
            color: Colors.orange.shade100,
            icon: questionIcon(),
            fontSize: 18.0,
          ),
        if (order.status == 'ABORTED')
          ResultWindow(
            text: AppStringValues.orderCancelled,
            color: Colors.red.shade100,
            icon: errorIcon(),
          ),
        if (order.status == 'PENDING')
          ResultWindow(
            text: AppStringValues.orderPending,
            color: Colors.blue.shade100,
            icon: waitingIcon(),
            fontSize: 18.0,
          ),
        if (order.status == 'READY')
          ResultWindow(
            text: AppStringValues.orderReady,
            color: role == 'customer' ? Colors.green.shade100 : Colors.blue.shade100,
            icon: checkIcon(
              color: role == 'customer' ? Colors.green.shade400 : Colors.blue.shade400,
            ),
          ),
        if (mode == 'after-creation')
          if (order.status == 'ACTIVE')
            ResultWindow(
              text: AppStringValues.orderRecieved,
              color: Colors.blue.shade100,
              icon: checkIcon(color: Colors.blue.shade400),
            ),
      ],
    );
  }
}

class QrCard extends StatelessWidget {
  //const QrCard({Key? key, required this.order}) : super(key: key);

  //final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(40)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(0.0, 0.0),
              blurRadius: 15.0,
              spreadRadius: 5.0),
        ],
      ),
      child: Column(
        children: [
          //QrImage(data: order.orderId, size: 220.0),
          QrImage(data: 'QR Coffee', size: 220.0),
          Text(
            //'${AppStringValues.orderCode}: "${order.orderId.substring(0, 6).toUpperCase()}"',
            'QR Coffee',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
