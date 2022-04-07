import 'package:flutter/material.dart';
import 'package:qr_coffee/models/customer.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details_customer.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';

Future moveOrderToPassive(Order order, OrderStatus status, Customer customer) async {
  await CompanyOrderDatabase(companyID: order.companyID).createPassiveOrder(
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

  await CompanyOrderDatabase(companyID: order.companyID).deleteActiveOrder(order.orderID);
  await CustomerOrderDatabase(userID: order.userID).deleteActiveOrder(order.orderID);

  // Refund order with Credits.
  if (status == OrderStatus.aborted) {
    customer.updateCredits(customer.credits + order.price);
  }
}

// Move order back to active orders.
Future repeatOrder(Order order, OrderStatus status, BuildContext previousContext) async {
  await CompanyOrderDatabase(companyID: order.companyID).createActiveOrder(
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

// Update order from OrderStatus.waiting to OrderStatus.ready.
Future updateOrderStatus(Order order, OrderStatus status) async {
  await CompanyOrderDatabase(companyID: order.companyID).updateOrderStatus(order.orderID, status);
  await CustomerOrderDatabase(userID: order.userID).updateOrderStatus(order.orderID, status);
}
