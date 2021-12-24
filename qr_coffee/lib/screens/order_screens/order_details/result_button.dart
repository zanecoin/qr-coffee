import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details.dart';
import 'package:qr_coffee/service/database.dart';

class ResultButton extends StatelessWidget {
  const ResultButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.order,
    required this.status,
    required this.previousContext,
    required this.role,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final Color color;
  final Order order;
  final String status;
  final BuildContext previousContext;
  final String role;

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
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
      onPressed: () {
        if (status == 'ACTIVE') {
          _repeatOrder();
        } else if (status == 'READY') {
          _updateOrderStatus();
        } else {
          _moveOrderToPassive();
        }
      },
    );
  }

  // MOVE ORDER TO PASSIVE ORDERS
  Future _moveOrderToPassive() async {
    await DatabaseService().createPassiveOrder(
      status,
      order.items,
      order.price,
      order.pickUpTime,
      order.username,
      order.place,
      order.orderId,
      order.userId,
      order.day,
      order.triggerNum,
    );

    await DatabaseService().deleteActiveOrder(order.orderId);
  }

  // MOVE ORDER BACK TO ACTIVE ORDERS
  Future _repeatOrder() async {
    DocumentReference _docRef = await DatabaseService().createActiveOrder(
      status,
      order.items,
      order.price,
      order.pickUpTime,
      order.username,
      order.place,
      '',
      order.userId,
      order.day,
      order.triggerNum,
    );

    await DatabaseService().updateOrderId(_docRef.id, status);
    order.orderId = _docRef.id;

    Navigator.pushReplacement(
      previousContext,
      new MaterialPageRoute(
        builder: (context) => OrderDetails(
          order: order,
          role: role,
          mode: 'normal',
        ),
      ),
    );
  }

  // UPDATE ORDER FROM 'READY' TO 'ACTIVE'
  Future _updateOrderStatus() async {
    await DatabaseService().updateOrderStatus(order.orderId, status);
  }
}
