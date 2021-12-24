import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_tile.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:qr_coffee/shared/widgets/custom_divider.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:intl/intl.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  late int _itemCount;
  @override
  void initState() {
    _itemCount = 5;
    super.initState();
  }

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
              _getPassiveOrdersForUser(snapshots.item3.data!, userData);
          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
          activeOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));
          passiveOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));
          passiveOrderList = passiveOrderList.reversed.toList();

          return Scaffold(
              appBar: customAppBar(context, title: Text('')),
              body: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 15),
                          Icon(Icons.check_circle, color: Colors.green),
                          _text(CzechStrings.activeOrders),
                        ],
                      ),
                      if (activeOrderList.length == 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Text(CzechStrings.noOrders),
                        ),
                      if (activeOrderList.length > 0)
                        SizedBox(
                          child: ListView.builder(
                            itemBuilder: (context, index) => OrderTile(
                              order: activeOrderList[index],
                              time: time,
                              role: 'customer',
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
                          _text(CzechStrings.orderHistory),
                        ],
                      ),
                      if (passiveOrderList.length == 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Text(CzechStrings.noOrders),
                        ),
                      if (passiveOrderList.length > 0)
                        Column(
                          children: [
                            SizedBox(
                              child: ListView.builder(
                                itemBuilder: (context, index) => OrderTile(
                                  order: passiveOrderList[index],
                                  time: time,
                                  role: 'customer',
                                ),
                                itemCount: _itemCount,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: NeverScrollableScrollPhysics(),
                              ),
                            ),
                            if (_itemCount + 5 < passiveOrderList.length)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _itemCount += 5;
                                  });
                                },
                                child: Text(CzechStrings.loadMore),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  primary: Colors.grey.shade700,
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
          return Container(color: Colors.white);
        }
      },
    );
  }

  List<Order> _getActiveOrdersForUser(
      List<Order> orderList, UserData userData) {
    List<Order> result = [];
    for (var item in orderList) {
      if (item.userId == userData.uid && item.status != 'PENDING') {
        result.add(item);
      }
    }
    return result;
  }

  List<Order> _getPassiveOrdersForUser(
      List<Order> orderList, UserData userData) {
    List<Order> result = [];
    for (var item in orderList) {
      if (item.userId == userData.uid) {
        result.add(item);
      }
    }
    return result;
  }

  Widget _text(String string) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        string,
        style: TextStyle(
          color: Colors.black,
          fontSize: Responsive.deviceWidth(context) > kDeviceUpperWidthTreshold
              ? 16
              : Responsive.width(4.2, context),
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
