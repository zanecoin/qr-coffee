import 'dart:async';
import 'package:cafe_app/models/coffee.dart';
import 'package:cafe_app/models/order.dart';
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/screens/customer_app/order_screen.dart';
import 'package:cafe_app/screens/shared_screens/order_inventory.dart';
import 'package:cafe_app/service/database.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:cafe_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'coffee_inventory.dart';

class CustomerHomeBody extends StatefulWidget {
  const CustomerHomeBody({Key? key}) : super(key: key);

  @override
  _CustomerHomeBodyState createState() => _CustomerHomeBodyState();
}

class _CustomerHomeBodyState extends State<CustomerHomeBody> {
  @override
  Widget build(BuildContext context) {
    // get currently logged user and theme provider
    final user = Provider.of<User?>(context);

    // get data streams
    return StreamBuilder5<UserData, List<Order>, List<Order>, List<Coffee>,
        dynamic>(
      streams: Tuple5(
        DatabaseService(uid: user!.uid).userData,
        DatabaseService().activeOrderList,
        DatabaseService().passiveOrderList,
        DatabaseService().coffeeList,
        Stream.periodic(const Duration(seconds: 1)),
      ),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData &&
            snapshots.item2.hasData &&
            snapshots.item3.hasData &&
            snapshots.item4.hasData) {
          UserData userData = snapshots.item1.data!;
          List<Order> activeOrderList =
              _getActiveOrdersForUser(snapshots.item2.data!, userData);
          List<Order> passiveOrderList =
              _getActiveOrdersForUser(snapshots.item3.data!, userData);
          List<Coffee> coffeeList = snapshots.item4.data!;
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
                      CustomDivider(padding: 10),
                      if (activeOrderList.length > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 15),
                                Icon(Icons.check_circle, color: Colors.green),
                                text('Vaše aktivní objednávky'),
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
                            CustomDivider(padding: 10),
                          ],
                        ),
                      if (passiveOrderList.length > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 15),
                                Icon(Icons.restore, color: Colors.blue),
                                text('Objednejte si na základě své historie'),
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
                            CustomDivider(padding: 10),
                          ],
                        ),
                      Row(
                        children: [
                          SizedBox(width: 15),
                          Icon(Icons.coffee_maker, color: Colors.brown),
                          text('Prohlédněte si druhy kávy'),
                        ],
                      ),
                      SizedBox(
                        height: Responsive.height(20, context),
                        child: ListView.builder(
                          itemBuilder: (context, index) =>
                              CoffeeKindTile(coffee: coffeeList[index]),
                          itemCount: coffeeList.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => OrderScreen(),
              ),
            );
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/cafeback2.jpg',
                  fit: BoxFit.fill,
                ),
              ),
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
                        'Objednat kávu nyní!',
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
      ),
    );
  }
}
