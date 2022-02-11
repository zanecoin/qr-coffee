import 'package:flutter/material.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ResultWindow extends StatelessWidget {
  const ResultWindow({Key? key, required this.text, required this.icon, required this.color})
      : super(key: key);

  final String text;
  final Widget icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 5),
            Text(text, style: TextStyle(fontSize: 20)),
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
            text: CzechStrings.orderCollected,
            color: Colors.green.shade100,
            icon: checkIcon(color: Colors.green.shade400),
          ),
        if (order.status == 'ABANDONED')
          ResultWindow(
            text: CzechStrings.orderAbandoned,
            color: Colors.orange.shade100,
            icon: questionIcon(),
          ),
        if (order.status == 'ABORTED')
          ResultWindow(
            text: CzechStrings.orderCancelled,
            color: Colors.red.shade100,
            icon: errorIcon(),
          ),
        if (order.status == 'PENDING')
          ResultWindow(
            text: CzechStrings.orderPending,
            color: Colors.blue.shade100,
            icon: waitingIcon(),
          ),
        if (order.status == 'READY')
          ResultWindow(
            text: CzechStrings.orderReady,
            color: role == 'customer' ? Colors.green.shade100 : Colors.blue.shade100,
            icon: checkIcon(
              color: role == 'customer' ? Colors.green.shade400 : Colors.blue.shade400,
            ),
          ),
        if (mode == 'after-creation')
          if (order.status == 'ACTIVE')
            ResultWindow(
              text: CzechStrings.orderRecieved,
              color: Colors.blue.shade100,
              icon: checkIcon(color: Colors.blue.shade400),
            ),
      ],
    );
  }
}

class QrCard extends StatelessWidget {
  const QrCard({Key? key, required this.order}) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(40)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(0, 0),
              blurRadius: 15.0,
              spreadRadius: 5.0),
        ],
      ),
      child: Column(
        children: [
          QrImage(data: order.orderId, size: 220),
          Text(
            '${CzechStrings.orderCode}: "${order.orderId.substring(0, 6).toUpperCase()}"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
