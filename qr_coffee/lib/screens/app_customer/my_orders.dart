import 'dart:math';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/customer.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_tile.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:qr_coffee/shared/widgets/custom_divider.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  late bool addButtonPressed;
  late int _itemCount;

  @override
  void initState() {
    addButtonPressed = false;
    _itemCount = 5;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userFromAuth = Provider.of<UserFromAuth?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return StreamBuilder4<Customer, List<Order>, List<Order>, dynamic>(
      streams: Tuple4(
        CustomerDatabase(userID: userFromAuth!.userID).customer,
        CustomerOrderDatabase(userID: userFromAuth.userID).activeOrderList,
        CustomerOrderDatabase(userID: userFromAuth.userID).passiveOrderList,
        Stream.periodic(const Duration(seconds: 1)),
      ),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData && snapshots.item2.hasData && snapshots.item3.hasData) {
          Customer customer = snapshots.item1.data!;
          List<Order> activeOrderList = _getActiveOrdersForUser(snapshots.item2.data!, customer);
          List<Order> passiveOrderList = _getPassiveOrdersForUser(snapshots.item3.data!, customer);
          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
          activeOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));
          passiveOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));
          passiveOrderList = passiveOrderList.reversed.toList();

          int itemRefreshedCount = min(5, passiveOrderList.length);

          if (addButtonPressed) {
            _itemCount = _itemCount;
          } else {
            _itemCount = itemRefreshedCount;
          }

          return Scaffold(
              backgroundColor: themeProvider.themeData().backgroundColor,
              appBar: customAppBar(context, title: Text('')),
              body: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 0, 15, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 15),
                          Icon(Icons.check_circle, color: Colors.green),
                          _text(AppStringValues.activeOrders, themeProvider),
                        ],
                      ),
                      if (activeOrderList.length == 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Text(
                            AppStringValues.noOrders,
                            style: TextStyle(color: themeProvider.themeAdditionalData().textColor),
                          ),
                        ),
                      if (activeOrderList.length > 0)
                        SizedBox(
                          child: ListView.builder(
                            itemBuilder: (context, index) => OrderTile(
                              order: activeOrderList[index],
                              time: time,
                              role: customer.role,
                            ),
                            itemCount: activeOrderList.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                          ),
                        ),
                      CustomDivider(padding: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 15),
                          Icon(Icons.restore, color: Colors.blue),
                          _text(AppStringValues.orderHistory, themeProvider),
                        ],
                      ),
                      if (passiveOrderList.length == 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Text(
                            AppStringValues.noOrders,
                            style: TextStyle(color: themeProvider.themeAdditionalData().textColor),
                          ),
                        ),
                      if (passiveOrderList.length > 0)
                        Column(
                          children: [
                            SizedBox(
                              child: ListView.builder(
                                itemBuilder: (context, index) => OrderTile(
                                  order: passiveOrderList[index],
                                  time: time,
                                  role: customer.role,
                                ),
                                itemCount: _itemCount,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: NeverScrollableScrollPhysics(),
                              ),
                            ),
                            if (_itemCount < passiveOrderList.length)
                              TextButton(
                                onPressed: () {
                                  int addOn = min(5, passiveOrderList.length - _itemCount);
                                  setState(() {
                                    _itemCount += addOn;
                                    addButtonPressed = true;
                                  });
                                },
                                child: Text(AppStringValues.loadMore),
                                style: TextButton.styleFrom(
                                  backgroundColor: themeProvider.themeAdditionalData().blendedColor,
                                  primary: themeProvider.themeAdditionalData().blendedInvertColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ));
        } else {
          return Container(color: themeProvider.themeAdditionalData().backgroundColor);
        }
      },
    );
  }

  List<Order> _getActiveOrdersForUser(List<Order> orderList, Customer customer) {
    List<Order> result = [];
    for (var item in orderList) {
      if (item.userID == customer.userID) {
        result.add(item);
      }
    }
    return result;
  }

  List<Order> _getPassiveOrdersForUser(List<Order> orderList, Customer customer) {
    List<Order> result = [];
    for (var item in orderList) {
      if (item.userID == customer.userID) {
        result.add(item);
      }
    }
    return result;
  }

  Widget _text(String string, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        string,
        style: TextStyle(
          color: themeProvider.themeAdditionalData().textColor,
          fontSize: Responsive.isLargeDevice(context) ? 16 : Responsive.width(4.2, context),
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
