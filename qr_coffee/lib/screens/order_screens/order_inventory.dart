import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:qr_coffee/shared/custom_small_widgets.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/image_banner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:intl/intl.dart';
import 'package:qr_coffee/shared/strings.dart';

// tile with order in the order list
class OrderTile extends StatelessWidget {
  final Order order;
  final String time;
  final String role;

  OrderTile({required this.order, required this.role, this.time = ''});

  @override
  Widget build(BuildContext context) {
    String coffeeLabel;
    String remainingTime;
    Widget icon;
    Color color;

    // czech language formatting
    if (order.coffee.length == 1) {
      coffeeLabel = order.coffee[0];
    } else if (order.coffee.length > 1 && order.coffee.length < 5) {
      coffeeLabel = '${order.coffee.length} položky';
    } else {
      coffeeLabel = '${order.coffee.length} položek';
    }

    if (order.state == 'active') {
      icon = waitingIcon();
    } else if (order.state == 'abandoned') {
      icon = questionIcon();
    } else if (order.state == 'aborted') {
      icon = errorIcon();
    } else {
      icon = checkIcon();
    }

    if (order.state == 'active') {
      List returnArray =
          time == '' ? ['?', Colors.black] : getRemainingTime(order, time);
      remainingTime = returnArray[0];
      color = returnArray[1];
    } else {
      remainingTime = '${timeFormatter(order.pickUpTime)}';
      color = Colors.black;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 5, vertical: role == 'worker-on' ? 5 : 10),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => UserOrder(order: order, role: role),
              ),
            );
          },
          child: Container(
            height: Responsive.height(15, context),
            width: Responsive.width(67, context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: Offset(1, 1),
                  blurRadius: 15,
                  spreadRadius: 0,
                )
              ],
              //border: Border.all(color: Colors.grey, width: 1.5),
            ),
            child: Center(
              child: Row(
                children: [
                  SizedBox(width: Responsive.width(3, context)),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ImageBanner(path: 'assets/cafe.jpg', size: 'small'),
                      if (role == 'worker-on')
                        Positioned(child: icon, top: 32.5),
                    ],
                  ),
                  SizedBox(width: Responsive.width(2, context)),
                  if (role == 'customer')
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$coffeeLabel',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${order.price} Kč'),
                        Text(remainingTime, style: TextStyle(color: color)),
                      ],
                    ),
                  if (role == 'worker-on')
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${order.username}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${coffeeLabel}'),
                        Text(remainingTime, style: TextStyle(color: color)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// screen with order summary
class UserOrder extends StatefulWidget {
  // GET USER DATA FORM PREVIOUS HOMESCREEN TO GET INIT VALUE FOR CARD SELECTION
  final Order order;
  final String role;
  UserOrder({Key? key, required this.order, required this.role})
      : super(key: key);

  @override
  _UserOrderState createState() => _UserOrderState(order: order, role: role);
}

class _UserOrderState extends State<UserOrder> {
  final Order order;
  final String role;
  _UserOrderState({required this.order, required this.role});

  @override
  Widget build(BuildContext context) {
    // get data streams
    return StreamBuilder2<UserData, dynamic>(
      streams: Tuple2(
        DatabaseService(uid: order.userId).userData,
        Stream.periodic(const Duration(seconds: 1)),
      ),
      builder: (context, snapshots) {
        UserData? userData = snapshots.item1.data;
        String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
        String remainingTime = '';
        Color color = Colors.black;

        if (order.state == 'active') {
          List returnArray =
              time == '' ? ['?', Colors.black] : getRemainingTime(order, time);
          remainingTime = returnArray[0];
          color = returnArray[1];
        } else {
          remainingTime = '${timeFormatter(order.pickUpTime)}';
          color = Colors.black;
        }

        return Scaffold(
          appBar: customAppBar(context,
              title: Text(remainingTime, style: TextStyle(color: color))),
          body: userData == null
              ? Center(
                  child: Text(
                    CzechStrings.userNotFound,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _fancyInfoCard(order, userData, role),
                      SizedBox(height: 10),
                      Text('Položky',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      CustomDivider(indent: 90),
                      SizedBox(
                        child: ListView.builder(
                          itemBuilder: (context, index) => Center(
                              child: Text(
                            order.coffee[index],
                            style: TextStyle(fontSize: 20),
                          )),
                          itemCount: order.coffee.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (order.state == 'active')
                        if (role == 'worker-on')
                          Column(
                            children: [
                              SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _resultBtn('abandoned', 'Nevyzvednuto',
                                      Icons.clear, Colors.red),
                                  _resultBtn('complete', 'Vyzvednuto',
                                      Icons.done, Colors.green),
                                ],
                              ),
                            ],
                          ),
                      if (order.state == 'active')
                        if (role == 'customer')
                          Column(
                            children: [
                              SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _resultBtn(
                                      'aborted',
                                      'Zrušit moji objednávku',
                                      Icons.clear,
                                      Colors.red),
                                ],
                              ),
                            ],
                          ),
                      // order result info window
                      if (order.state == 'complete')
                        _resultWindow('Objednávka vyzvednuta',
                            Colors.green.shade100, checkIcon()),
                      if (order.state == 'abandoned')
                        _resultWindow('Objednávka nevyzvednuta',
                            Colors.orange.shade100, questionIcon()),
                      if (order.state == 'aborted')
                        _resultWindow('Objednávka zrušena', Colors.red.shade100,
                            errorIcon()),
                      if (order.state != 'active' && role == 'customer')
                        Column(
                          children: [
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _resultBtn('active', 'Objednat znovu',
                                    Icons.refresh, Colors.green),
                              ],
                            ),
                            Text(
                              'Na ${timeFormatter(order.pickUpTime).substring(0, 5)}',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              '(Platba uloženou kartou)',
                              style: TextStyle(fontSize: 18),
                            )
                          ],
                        ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _resultWindow(String text, Color color, Widget icon) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 35),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(
              width: 5,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultBtn(String result, String text, IconData icon, Color color) {
    return TextButton(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: color),
            Text(
              text,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
      onPressed: () {
        if (result == 'active') {
          _repeatOrder(result, order, context);
        } else {
          _answerOrder(result, order, context);
        }
      },
    );
  }
}

Widget _fancyInfoCard(Order order, UserData userData, String role) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    child: Card(
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.2), BlendMode.dstATop),
                      image: AssetImage('assets/cafe.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (role == 'worker-on')
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Text(
                    order.username,
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    order.flag,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          if (role == 'customer')
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    '${order.price.toString()} Kč',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    order.place,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

// move Order to passive orders
Future _answerOrder(String result, Order order, BuildContext context) async {
  await DatabaseService().createOrder(
    result,
    order.coffee,
    order.price,
    order.pickUpTime,
    order.username,
    order.flag,
    order.place,
    order.orderId,
    order.userId,
  );

  await DatabaseService().deleteOrder(order.orderId);
  Navigator.pop(context);
}

// move Order back to active orders
Future _repeatOrder(String result, Order order, BuildContext context) async {
  DocumentReference _docRef = await DatabaseService().createOrder(
    result,
    order.coffee,
    order.price,
    order.pickUpTime,
    order.username,
    order.flag,
    order.place,
    '',
    order.userId,
  );
  await DatabaseService().setOrderId(
    result,
    order.coffee,
    order.price,
    order.pickUpTime,
    order.username,
    order.flag,
    order.place,
    _docRef.id,
    order.userId,
  );

  Navigator.pop(context);
}
