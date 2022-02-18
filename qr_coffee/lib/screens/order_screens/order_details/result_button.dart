import 'package:flutter/material.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_details/result_function.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class ResultButton extends StatelessWidget {
  const ResultButton({
    Key? key,
    required this.userData,
    required this.text,
    required this.icon,
    required this.color,
    required this.order,
    required this.status,
    required this.previousContext,
  }) : super(key: key);

  final UserData userData;
  final String text;
  final IconData icon;
  final Color color;
  final Order order;
  final String status;
  final BuildContext previousContext;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: color),
            Text(
              text,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
      onPressed: () {
        if (status == 'ACTIVE') {
          repeatOrder(order, status, previousContext);
        } else if (status == 'READY') {
          updateOrderStatus(order, status);
          customSnackbar(
            context: context,
            text: '${AppStringValues.orderStatusChange}${AppStringValues.orderReady}',
          );
        } else {
          moveOrderToPassive(order, status, userData);
          if (status == 'COMPLETED')
            customSnackbar(
              context: context,
              text: '${AppStringValues.orderStatusChange}${AppStringValues.orderCollected}',
            );
          if (status == 'ABANDONED')
            customSnackbar(
              context: context,
              text: '${AppStringValues.orderStatusChange}${AppStringValues.orderAbandoned}',
            );
        }
      },
    );
  }
}
