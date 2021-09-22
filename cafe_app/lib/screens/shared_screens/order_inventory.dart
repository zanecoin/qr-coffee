import 'package:cafe_app/models/order.dart';
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/service/database.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:cafe_app/shared/image_banner.dart';
import 'package:cafe_app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:intl/intl.dart';

List<dynamic> _getRemainingTime(Order order, String time) {
  String result;
  Color color;
  int m1 = int.parse(order.pickUpTime.substring(10, 12)); // minutes
  int m2 = int.parse(time.substring(10, 12));
  int h1 = int.parse(order.pickUpTime.substring(0, 10)); // date and hours
  int h2 = int.parse(time.substring(0, 10));
  int difference = m1 - m2 + 60 * (h1 - h2);
  // print('////////');
  // print(order.pickUpTime);
  // print(time);
  // print(difference);
  if (difference < 30) {
    result = (int.parse(order.pickUpTime.substring(10, 12)) -
            int.parse(time.substring(10, 12)))
        .toString();
    if (int.parse(result) > 2) {
      result = 'Za $result min';
      color = Colors.green.shade800;
    } else if (int.parse(result) > -1) {
      result = 'Za $result min';
      color = Colors.yellow.shade800;
    } else {
      result = 'Před ${-int.parse(result)} min';
      color = Colors.red.shade700;
    }
  } else {
    result = 'Před více než 30 min';
    color = Colors.black;
  }
  //print(result);
  return [result, color];
}

String _timeFormatter(String time) {
  return '${time.substring(8, 10)}:${time.substring(10, 12)} • ${time.substring(6, 8)}.${time.substring(4, 6)}.${time.substring(0, 4)}';
}

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
      coffeeLabel = '${order.coffee.length} kávy';
    } else {
      coffeeLabel = '${order.coffee.length} káv';
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
          time == '' ? ['?', Colors.black] : _getRemainingTime(order, time);
      remainingTime = returnArray[0];
      color = returnArray[1];
    } else {
      remainingTime = '${_timeFormatter(order.pickUpTime)}';
      color = Colors.black;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 5, vertical: role == 'worker' ? 5 : 10),
      child: Card(
        elevation: 4,
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
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey, width: 1.5),
            ),
            child: Center(
              child: Row(
                children: [
                  SizedBox(width: Responsive.width(3, context)),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ImageBanner(path: 'assets/cafe.jpg', size: 'small'),
                      if (role == 'worker') Positioned(child: icon, top: 32.5),
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
                  if (role == 'worker')
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            order.spz == ''
                                ? '${order.username}'
                                : '${order.username}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        if (order.spz != '') Text('${order.spz}'),
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
        if (snapshots.item1.hasData) {
          UserData userData = snapshots.item1.data!;
          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
          String remainingTime = '';
          Color color = Colors.black;

          if (order.state == 'active') {
            List returnArray = time == ''
                ? ['?', Colors.black]
                : _getRemainingTime(order, time);
            remainingTime = returnArray[0];
            color = returnArray[1];
          } else {
            remainingTime = '${_timeFormatter(order.pickUpTime)}';
            color = Colors.black;
          }

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 22),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: Text(remainingTime, style: TextStyle(color: color)),
              centerTitle: true,
              elevation: 5,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _fancyInfoCard(order, userData, role),
                  SizedBox(height: 10),
                  Text('Položky',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    if (role == 'worker')
                      Column(
                        children: [
                          SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _resultBtn('abandoned', 'Nevyzvednuto',
                                  Icons.clear, Colors.red),
                              _resultBtn('complete', 'Vyzvednuto', Icons.done,
                                  Colors.green),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _resultBtn('aborted', 'Zrušit moji objednávku',
                                  Icons.clear, Colors.red),
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
                    _resultWindow(
                        'Objednávka zrušena', Colors.red.shade100, errorIcon()),
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
                          'Na ${_timeFormatter(order.pickUpTime).substring(0, 5)}',
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
        } else {
          return Loading();
        }
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
          if (role == 'worker')
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
                    order.spz,
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
    order.spz,
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
    order.spz,
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
    order.spz,
    order.place,
    _docRef.id,
    order.userId,
  );

  Navigator.pop(context);
}
