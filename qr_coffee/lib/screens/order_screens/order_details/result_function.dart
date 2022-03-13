import 'package:flutter/material.dart';
import 'package:qr_coffee/models/customer.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details_customer.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';

Future moveOrderToPassive(Order order, String status, Customer customer) async {
  await CompanyOrderDatabase().createPassiveOrder(
    status,
    order.items,
    order.price,
    order.pickUpTime,
    order.username,
    order.shop,
    order.company,
    order.orderID,
    order.userID,
    order.shopID,
    order.companyID,
    order.day,
  );

  await CustomerOrderDatabase(userID: order.userID).createPassiveOrder(
    status,
    order.items,
    order.price,
    order.pickUpTime,
    order.username,
    order.shop,
    order.company,
    order.orderID,
    order.shopID,
    order.companyID,
    order.day,
  );

  await CompanyOrderDatabase().deleteActiveOrder(order.orderID);
  await CustomerOrderDatabase(userID: order.userID).deleteActiveOrder(order.orderID);

  // Refund order with QR Tokens.
  customer.updateTokens(customer.tokens + order.price);
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
    order.userID,
    order.shopID,
    order.companyID,
    order.day,
  );

  await CustomerOrderDatabase(userID: order.userID).createActiveOrder(
    status,
    order.items,
    order.price,
    order.pickUpTime,
    order.username,
    order.shop,
    order.company,
    '',
    order.shopID,
    order.companyID,
    order.day,
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
  await CompanyOrderDatabase().updateOrderStatus(order.orderID, status);
  await CustomerOrderDatabase(userID: order.userID).updateOrderStatus(order.orderID, status);
}
