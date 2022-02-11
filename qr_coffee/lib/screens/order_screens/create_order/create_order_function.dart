import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/api/manual_api_order.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/order.dart';
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
  String? _currentPlace,
  int paymentMethod,
  String role,
  double plusTime,
) async {
  int price = getTotalPrice(items, _selectedItems);

  if (_selectedItems.isEmpty ||
      (_currentPlace == null && role != 'worker') ||
      (paymentMethod == 2 && price > userData.tokens && role != 'worker')) {
    // NOTIFY USER SOMETHING IS WRONG WITH ORDER PARAMETERS
    String message = '';

    if (_selectedItems.isEmpty && _currentPlace != null) {
      message = CzechStrings.chooseItemsDot;
    } else if (_selectedItems.isNotEmpty && _currentPlace == null) {
      message = CzechStrings.choosePlaceDot;
    } else if (paymentMethod == 2 && price > userData.tokens) {
      message = CzechStrings.insufficientTokenBalace;
    } else if (_selectedItems.isEmpty && _currentPlace == null && role == 'worker') {
      message = CzechStrings.chooseItemsDot;
    } else {
      message = CzechStrings.chooseBothDot;
    }
    customSnackbar(context: context, text: message);

    return 0;
  } else {
    // CREATE ORDER PARAMETERS
    String status = 'COMPLETED';
    String username = 'generated-order';
    String userId = 'generated-order^^';
    String pickUpTime = getPickUpTime(0);
    String shop = userData.shop;
    String company = '??';
    String shopId = '??';
    String companyId = '??';

    if (role == 'customer') {
      status = paymentMethod == 1 ? 'PENDING' : 'ACTIVE';
      username = '${userData.name} ${userData.surname}';
      pickUpTime = getPickUpTime(plusTime);
      shop = _currentPlace.toString();
      userId = userData.uid;
    }

    List<String> stringList = getStringList(_selectedItems);
    String orderId = '';
    String day = DateFormat('EEEE').format(DateTime.now());
    int triggerNum = 0;

    DocumentReference _docRef;
    if (role == 'worker') {
      // PLACE A PASSIVE ORDER TO DATABASE
      _docRef = await CompanyOrderDatabase().createPassiveOrder(status, stringList, price,
          pickUpTime, username, shop, company, orderId, userId, shopId, companyId, day, triggerNum);
    } else {
      // PLACE AN ACTIVE ORDER TO COMPANY COLLECTION
      _docRef = await CompanyOrderDatabase().createActiveOrder(status, stringList, price,
          pickUpTime, username, shop, company, orderId, userId, shopId, companyId, day, triggerNum);

      // PLACE AN ACTIVE ORDER TO USER COLLECTION
      await UserOrderDatabase(uid: userId).createActiveOrder(status, stringList, price, pickUpTime,
          username, shop, company, _docRef.id, userId, shopId, companyId, day, triggerNum);
    }

    // UPDATE QUANTITY OF A PARTICULAR ITEM TYPE
    for (Product item in _selectedItems) {
      print(item.name);
      await ProductDatabase().updateProductData(item.uid, item.count + 1);
    }

    // CREATE ORDER INSTANCE TO SHOW IT TO USER AFTER SUCCESFUL ORDER
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
      // UPDATE USER DATA
      await UserDatabase(uid: userData.uid).updateNumOrders(userData.numOrders + 1);

      if (paymentMethod == 1) {
        // LAUNCH WEBVIEW
        launchPaymentGateway(context, price, items, order);
      } else {
        // SUBTRACT THE AMOUNT OF TOKENS FROM USER
        await UserDatabase(uid: userData.uid).updateUserTokens(userData.tokens - price);
        Navigator.pop(context);
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => OrderDetailsCustomer(order: order, mode: 'after-creation'),
          ),
        );
      }
    } else {
      Navigator.pop(context);
      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => OrderDetailsWorker(order: order, mode: 'normal'),
        ),
      );
      customSnackbar(context: context, text: CzechStrings.orderCreationSuccess);
    }

    return 1;
  }
}
