// Move order to passive orders.
import 'package:flutter/material.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details_customer.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';

Future moveOrderToPassive(Order order, String status, UserData userData) async {
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
Future repeatOrder(Order order, String status, BuildContext previousContext) async {
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

// Update order from 'active' to 'ready'.
Future updateOrderStatus(Order order, String status) async {
  await CompanyOrderDatabase().updateOrderStatus(order.orderId, status);
  await UserOrderDatabase(uid: order.userId).updateOrderStatus(order.orderId, status);
}
