import 'dart:async';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_inventory.dart';
import 'package:qr_coffee/screens/order_screens/set_order_frame.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/custom_small_widgets.dart';
import 'package:qr_coffee/shared/loading.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CustomerHomeBody extends StatefulWidget {
  const CustomerHomeBody({Key? key}) : super(key: key);

  @override
  _CustomerHomeBodyState createState() => _CustomerHomeBodyState();
}

class _CustomerHomeBodyState extends State<CustomerHomeBody> {
  @override
  Widget build(BuildContext context) {
    // GET CURRENTLY LOGGED USER AND DATA STREAMS
    final user = Provider.of<User?>(context);
    return StreamBuilder4<UserData, List<Order>, List<Order>, dynamic>(
      streams: Tuple4(
        DatabaseService(uid: user!.uid).userData,
        DatabaseService().activeOrderList,
        DatabaseService().passiveOrderList,
        Stream.periodic(const Duration(seconds: 1)),
      ),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData &&
            snapshots.item2.hasData &&
            snapshots.item3.hasData) {
          UserData userData = snapshots.item1.data!;
          List<Order> activeOrderList =
              _getActiveOrdersForUser(snapshots.item2.data!, userData);
          List<Order> passiveOrderList =
              _getActiveOrdersForUser(snapshots.item3.data!, userData);
          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

          activeOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));
          passiveOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));
          activeOrderList = activeOrderList.reversed.toList();
          passiveOrderList = passiveOrderList.reversed.toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _proceedToOrder(userData),
                      if (activeOrderList.length > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDivider(padding: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 15),
                                Icon(Icons.check_circle, color: Colors.green),
                                text(CzechStrings.activeOrders),
                              ],
                            ),
                            SizedBox(
                              height: Responsive.height(20, context),
                              child: ListView.builder(
                                itemBuilder: (context, index) => OrderTile(
                                  order: activeOrderList[index],
                                  time: time,
                                  role: 'customer',
                                ),
                                itemCount: activeOrderList.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ],
                        ),
                      if (passiveOrderList.length > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDivider(padding: 10),
                            Row(
                              children: [
                                SizedBox(width: 15),
                                Icon(Icons.restore, color: Colors.blue),
                                text(CzechStrings.orderHistory),
                              ],
                            ),
                            SizedBox(
                              height: Responsive.height(20, context),
                              child: ListView.builder(
                                itemBuilder: (context, index) => OrderTile(
                                  order: passiveOrderList[index],
                                  time: time,
                                  role: 'customer',
                                ),
                                itemCount: passiveOrderList.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }

  List<Order> _getActiveOrdersForUser(
      List<Order> orderList, UserData userData) {
    List<Order> result = [];
    for (var item in orderList) {
      if (item.userId == userData.uid) result.add(item);
    }
    return result;
  }

  Widget text(String string) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        string,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _proceedToOrder(UserData userData) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
        image: DecorationImage(
          colorFilter: new ColorFilter.mode(
            Colors.black.withOpacity(1),
            BlendMode.dstATop,
          ),
          image: AssetImage('assets/cafeteria1.jpg'),
          fit: BoxFit.cover,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade600,
            offset: Offset(1, 1),
            blurRadius: 10,
            spreadRadius: 0,
          )
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => SetOrderFrame(),
            ),
          );
        },
        child: Stack(
          children: [
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Text(
                      CzechStrings.createOrder,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 16,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(30),
//                       topRight: Radius.circular(30),
//                     ),
//                     image: DecorationImage(
//                       colorFilter: new ColorFilter.mode(
//                         Colors.black.withOpacity(0),
//                         BlendMode.dstATop,
//                       ),
//                       image: AssetImage('assets/cafeback2.jpg'),
//                       fit: BoxFit.cover,
//                     ),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.shade600,
//                         offset: Offset(1, 1),
//                         blurRadius: 15,
//                         spreadRadius: 0,
//                       )
//                     ],
//                   ),