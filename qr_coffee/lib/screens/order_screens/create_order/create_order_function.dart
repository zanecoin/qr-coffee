import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/api/manual_api_order.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details_customer.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details_worker.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:intl/intl.dart';
import 'package:qr_coffee/shared/widgets/custom_snackbar.dart';

Future<int> createOrderFunction(
  BuildContext context,
  List<Product> items,
  UserData userData,
  List<dynamic> _selectedItems,
  Shop currentShop,
  int paymentMethod,
  String role,
  double plusTime,
) async {
  int price = getTotalPrice(items, _selectedItems);

  if (_selectedItems.isEmpty ||
      (paymentMethod == 2 && price > userData.tokens && role != 'worker')) {
    // Notify user something is wrong with order parameters.

    String message = '';
    if (_selectedItems.isEmpty) {
      message = AppStringValues.chooseItemsDot;
    } else if (paymentMethod == 2 && price > userData.tokens) {
      message = AppStringValues.insufficientTokenBalace;
    }
    customSnackbar(context: context, text: message);

    return 0;
  } else {
    // Create order parameters.

    String status = 'COMPLETED';
    String username = 'generated-order';
    String userId = 'generated-order^^';
    String pickUpTime = getPickUpTime(0);
    String shop = currentShop.address;
    String shopId = currentShop.uid;
    String company = currentShop.company;
    String companyId = currentShop.companyId;

    if (role == 'customer') {
      status = paymentMethod == 1 ? 'PENDING' : 'ACTIVE';
      username = '${userData.name} ${userData.surname}';
      pickUpTime = getPickUpTime(plusTime);
      userId = userData.uid;
    }

    List<String> stringList = getStringList(_selectedItems);
    String orderId = '';
    String day = DateFormat('EEEE').format(DateTime.now());
    int triggerNum = 0;

    DocumentReference _docRef;
    if (role == 'worker') {
      // Place a passive order to database if order is generated by worker.
      _docRef = await CompanyOrderDatabase().createPassiveOrder(status, stringList, price,
          pickUpTime, username, shop, company, orderId, userId, shopId, companyId, day, triggerNum);
    } else {
      // Place an active order to company collection.
      _docRef = await CompanyOrderDatabase().createActiveOrder(status, stringList, price,
          pickUpTime, username, shop, company, orderId, userId, shopId, companyId, day, triggerNum);

      // Place an active order to user collection.
      await UserOrderDatabase(uid: userId).createActiveOrder(status, stringList, price, pickUpTime,
          username, shop, company, _docRef.id, userId, shopId, companyId, day, triggerNum);
    }

    // Update quantity of a particular item type.
    for (Product item in _selectedItems) {
      print(item.name);
      await ProductDatabase().updateProductData(item.uid, item.count + 1);
    }

    // Create order instance to show it to user after succesful order.
    Order order = Order(
      status: status,
      items: stringList,
      price: price,
      pickUpTime: pickUpTime,
      username: username,
      shop: shop,
      company: company,
      orderId: _docRef.id,
      userId: userId,
      shopId: shopId,
      companyId: companyId,
      day: day,
      triggerNum: triggerNum,
    );

    if (role == 'customer') {
      // Update user data.
      try {
        await UserDatabase(uid: userData.uid).updateNumOrders(userData.numOrders + 1);
      } catch (e) {
        customSnackbar(context: context, text: e.toString());
        return 0;
      }
      if (paymentMethod == 1) {
        // Launch webview.
        launchPaymentGateway(context, price, items, order);
      } else {
        // Subtract the amount of tokens from user.
        try {
          await UserDatabase(uid: userData.uid).updateUserTokens(userData.tokens - price);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => OrderDetailsCustomer(order: order, mode: 'after-creation'),
            ),
          );
        } catch (e) {
          customSnackbar(context: context, text: e.toString());
          return 0;
        }
      }
    } else {
      // Create order generated by worker (order is independent of any user account).
      Navigator.pop(context);
      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => OrderDetailsWorker(order: order, mode: 'normal'),
        ),
      );
      customSnackbar(context: context, text: AppStringValues.orderCreationSuccess);
    }

    return 1;
  }
}
