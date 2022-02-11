import 'package:flutter/material.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details_customer.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';

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
    required this.role,
  }) : super(key: key);

  final UserData userData;
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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

  // Move order to passive orders.
  Future _moveOrderToPassive() async {
    await CompanyOrderDatabase().createPassiveOrder(
      status,
      order.items,
      order.price,
      order.pickUpTime,
      order.username,
      order.shop,
      order.company,
      order.orderId,
      order.userId,
      order.shopId,
      order.companyId,
      order.day,
      order.triggerNum,
    );

    await UserOrderDatabase(uid: order.userId).createPassiveOrder(
      status,
      order.items,
      order.price,
      order.pickUpTime,
      order.username,
      order.shop,
      order.company,
      order.orderId,
      order.userId,
      order.shopId,
      order.companyId,
      order.day,
      order.triggerNum,
    );

    await CompanyOrderDatabase().deleteActiveOrder(order.orderId);
    await UserOrderDatabase(uid: order.userId).deleteActiveOrder(order.orderId);

    // REFUND ORDER WITH QR TOKENS
    if (status == 'ABORTED') {
      await UserDatabase(uid: userData.uid).updateUserTokens(userData.tokens + order.price);
    }
  }

  // Move order back to active orders.
  Future _repeatOrder() async {
    await CompanyOrderDatabase().createActiveOrder(
      status,
      order.items,
      order.price,
      order.pickUpTime,
      order.username,
      order.shop,
      order.company,
      '',
      order.userId,
      order.shopId,
      order.companyId,
      order.day,
      order.triggerNum,
    );

    await UserOrderDatabase(uid: order.userId).createActiveOrder(
      status,
      order.items,
      order.price,
      order.pickUpTime,
      order.username,
      order.shop,
      order.company,
      '',
      order.userId,
      order.shopId,
      order.companyId,
      order.day,
      order.triggerNum,
    );

    Navigator.pushReplacement(
      previousContext,
      new MaterialPageRoute(
        builder: (context) => OrderDetailsCustomer(
          order: order,
          mode: 'normal',
        ),
      ),
    );
  }

  // UPDATE ORDER FROM 'ACTIVE' TO 'READY'
  Future _updateOrderStatus() async {
    await CompanyOrderDatabase().updateOrderStatus(order.orderId, status);
    await UserOrderDatabase(uid: order.userId).updateOrderStatus(order.orderId, status);
  }
}
