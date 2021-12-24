import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/api/manual_api_order.dart';
import 'package:qr_coffee/models/item.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:intl/intl.dart';

Future<int> createOrder(
  BuildContext context,
  List<Item> items,
  UserData userData,
  List<dynamic> _selectedItems,
  String? _currentPlace,
  int paymentMethod,
  String role,
  double plusTime,
) async {
  int price = getTotalPrice(items, _selectedItems);

  if (_selectedItems.isEmpty ||
      _currentPlace == null ||
      (paymentMethod == 2 && price > userData.tokens && role != 'worker-on')) {
    // NOTIFY USER SOMETHING IS WRONG WITH ORDER PARAMETERS
    String message;

    if (_selectedItems.isEmpty && _currentPlace != null) {
      message = CzechStrings.chooseItemsDot;
    } else if (_selectedItems.isNotEmpty && _currentPlace == null) {
      message = CzechStrings.choosePlaceDot;
    } else if (paymentMethod == 2 && price > userData.tokens) {
      message = CzechStrings.insufficientTokenBalace;
    } else {
      message = CzechStrings.chooseBothDot;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: 2000),
      ),
    );

    return 0;
  } else {
    // CREATE ORDER PARAMETERS
    String status = 'COMPLETED';
    String username = 'generated-order^^';

    if (role == 'customer' || role == 'worker-off') {
      status = paymentMethod == 1 ? 'PENDING' : 'ACTIVE';
      username = '${userData.name} ${userData.surname}';
    }

    List<String> stringList = getStringList(_selectedItems);
    String pickUpTime = getPickUpTime(plusTime);
    String place = _currentPlace.toString();
    String orderId = '';
    String userId = userData.uid;
    String day = DateFormat('EEEE').format(DateTime.now());
    int triggerNum = 0;

    // PLACE AN ACTIVE ORDER TO DATABASE
    DocumentReference _docRef = await DatabaseService().createActiveOrder(
      status,
      stringList,
      price,
      pickUpTime,
      username,
      place,
      orderId,
      userId,
      day,
      triggerNum,
    );

    // UPDATE ORDER WITH ID
    await DatabaseService().updateOrderId(_docRef.id, status);

    // UPDATE QUANTITY OF A PARTICULAR ITEM TYPE
    for (Item item in _selectedItems) {
      print(item.name);
      await DatabaseService().updateCoffeeData(item.uid, item.name, item.type,
          item.price, item.count + 1, item.picture);
    }

    // CREATE ORDER INSTANCE TO SHOW IT TO USER AFTER SUCCESFUL ORDER
    Order order = Order(
      status: status,
      items: stringList,
      price: price,
      pickUpTime: pickUpTime,
      username: username,
      place: place,
      orderId: _docRef.id,
      userId: userId,
      day: day,
      triggerNum: triggerNum,
    );

    if (role == 'customer' || role == 'worker-off') {
      // UPDATE USER DATA
      await DatabaseService(uid: userData.uid).updateUserData(
        userData.name,
        userData.surname,
        userData.email,
        userData.role,
        userData.tokens,
        userData.stand,
        userData.numOrders + 1,
      );

      if (paymentMethod == 1) {
        // LAUNCH WEBVIEW
        launchPaymentGateway(context, price, items, order);
      } else {
        // SUBTRACT THE AMOUNT OF TOKENS FROM USER
        await DatabaseService(uid: userData.uid).updateUserData(
          userData.name,
          userData.surname,
          userData.email,
          userData.role,
          userData.tokens - price,
          userData.stand,
          userData.numOrders,
        );
        Navigator.pop(context);
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => OrderDetails(
              role: 'customer',
              order: order,
              mode: 'after-creation',
            ),
          ),
        );
      }
    } else {
      Navigator.pop(context);
      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => OrderDetails(
            role: 'worker-on',
            order: order,
            mode: 'normal',
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(CzechStrings.orderCreationSuccess),
          duration: Duration(milliseconds: 2000),
        ),
      );
    }

    return 1;
  }
}
