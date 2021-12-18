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
import 'package:qr_coffee/shared/loading.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_flutter/qr_flutter.dart';

// TILE WITH ORDER IN ORDER LIST
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
    Color color = Colors.black;
    ;

    // CZECH LANGUAGE FORMATTING
    if (order.items.length == 1) {
      coffeeLabel = order.items[0];
    } else if (order.items.length > 1 && order.items.length < 5) {
      coffeeLabel = '${order.items.length} položky';
    } else {
      coffeeLabel = '${order.items.length} položek';
    }

    // ICON CHOOSER
    if (order.status == 'ACTIVE' || order.status == 'READY') {
      icon = waitingIcon();
    } else if (order.status == 'ABANDONED') {
      icon = questionIcon();
    } else if (order.status == 'ABORTED') {
      icon = errorIcon();
    } else {
      icon = checkIcon(color: Colors.green.shade400);
    }

    // INFORMATION HEADER FORMAT CHOOSER
    if (order.status == 'ACTIVE' || order.status == 'READY') {
      List returnArray =
          time == '' ? ['?', Colors.black] : getRemainingTime(order, time);
      remainingTime = returnArray[0];
      color = returnArray[1];
    } else if (order.status == 'PENDING') {
      remainingTime = CzechStrings.orderPending;
    } else {
      remainingTime = '${timeFormatter(order.pickUpTime)}';
    }

    // THE WIDGET ITSELF
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                builder: (context) => UserOrder(
                  order: order,
                  role: role,
                  mode: 'normal',
                ),
              ),
            );
          },
          child: Container(
            height: Responsive.height(15, context),
            width: Responsive.width(67, context),
            decoration: BoxDecoration(
              color:
                  order.status == 'READY' ? Colors.blue.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: Offset(1, 1),
                  blurRadius: 15,
                  spreadRadius: 0,
                )
              ],
            ),
            child: Center(
              child: Row(
                children: [
                  SizedBox(width: Responsive.width(3, context)),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ImageBanner(
                        path: order.status == 'READY'
                            ? 'assets/cafe_blue.png'
                            : 'assets/cafe.jpg',
                        size: 'small',
                        color: order.status == 'READY'
                            ? Colors.blue.shade100
                            : Colors.white,
                      ),
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
                        Text('${order.price} ${CzechStrings.currency}'),
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

// SCREEN WITH ORDER SUMMARY -------------------------------------------------------------------------------------------
class UserOrder extends StatefulWidget {
  // GET USER DATA FORM PREVIOUS HOMESCREEN TO GET INIT VALUE FOR CARD SELECTION
  final Order order;
  final String role;
  final String mode;
  UserOrder(
      {Key? key, required this.order, required this.role, required this.mode})
      : super(key: key);

  @override
  _UserOrderState createState() =>
      _UserOrderState(staticOrder: order, role: role, mode: mode);
}

class _UserOrderState extends State<UserOrder> {
  final Order staticOrder;
  final String role;
  final String mode;
  _UserOrderState(
      {required this.staticOrder, required this.role, required this.mode});

  bool _showButtons = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder3<UserData, List<Order>, dynamic>(
        streams: Tuple3(
          DatabaseService(uid: staticOrder.userId).userData,
          DatabaseService().activeOrderList,
          Stream.periodic(const Duration(seconds: 1)),
        ),
        builder: (context, snapshots) {
          if (snapshots.item2.hasData) {
            UserData? userData = snapshots.item1.data;
            Order? order = mode == 'normal'
                ? staticOrder
                : _getUpdatedOrder(snapshots.item2.data!, staticOrder);
            String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
            String remainingTime = '';
            Color color = Colors.black;

            if (order == null) {
              return Scaffold(
                appBar: customAppBar(context, title: Text('')),
                body: Center(
                  child: Text(
                    CzechStrings.orderNotFound,
                  ),
                ),
              );
            } else {
              // INFORMATION HEADER FORMAT CHOOSER
              if (order.status == 'ACTIVE') {
                List returnArray = time == ''
                    ? ['?', Colors.black]
                    : getRemainingTime(order, time);
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
                            if (role == 'customer' || role == 'worker-off')
                              _QrCard(order, userData, role),
                            if (role == 'worker-on')
                              _fancyInfoCard(order, userData),
                            SizedBox(height: 10),

                            // ORDER HEADER INFO -----------------------------
                            if (role == 'customer')
                              Text(
                                '${order.price.toString()} Kč',
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            if (role == 'customer')
                              Text(
                                order.place,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            if (role == 'customer' || role == 'worker-off')
                              CustomDivider(indent: 40),
                            SizedBox(
                              child: ListView.builder(
                                itemBuilder: (context, index) => Center(
                                    child: Text(
                                  order.items[index],
                                  style: TextStyle(fontSize: 20),
                                )),
                                itemCount: order.items.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                physics: NeverScrollableScrollPhysics(),
                              ),
                            ),
                            SizedBox(height: 10),

                            // ACTION BUTTONS -----------------------------------
                            if (order.status == 'ACTIVE' &&
                                role == 'worker-on' &&
                                mode == 'normal')
                              _resultBtn(
                                'READY',
                                CzechStrings.ready,
                                Icons.done,
                                Colors.green,
                                order,
                              ),
                            if (order.status == 'READY' &&
                                role == 'worker-on' &&
                                mode == 'normal' &&
                                _showButtons)
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _resultBtn(
                                          'ABANDONED',
                                          CzechStrings.abandoned,
                                          Icons.clear,
                                          Colors.red,
                                          order),
                                      _resultBtn(
                                          'COMPLETED',
                                          CzechStrings.collected,
                                          Icons.done,
                                          Colors.green,
                                          order),
                                    ],
                                  ),
                                ],
                              ),
                            if (order.status == 'READY' &&
                                role == 'worker-on' &&
                                mode == 'normal' &&
                                !_showButtons)
                              Column(
                                children: [
                                  SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showButtons = true;
                                      });
                                    },
                                    child: Text(CzechStrings.manualAnswer),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.grey.shade100,
                                      primary: Colors.grey.shade700,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                    ),
                                  ),
                                ],
                              ),
                            if ((order.status == 'ACTIVE' ||
                                    order.status == 'READY') &&
                                role == 'customer' &&
                                mode == 'normal')
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _resultBtn(
                                        'ABORTED',
                                        CzechStrings.cancelOrder,
                                        Icons.clear,
                                        Colors.red,
                                        order,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                            // ORDER RESULT INFO WINDOW ----------------------------
                            if (order.status != 'ACTIVE') SizedBox(height: 30),
                            if (order.status == 'COMPLETED')
                              _resultWindow(
                                CzechStrings.orderCollected,
                                Colors.green.shade100,
                                checkIcon(color: Colors.green.shade400),
                              ),
                            if (order.status == 'ABANDONED')
                              _resultWindow(
                                CzechStrings.orderAbandoned,
                                Colors.orange.shade100,
                                questionIcon(),
                              ),
                            if (order.status == 'ABORTED')
                              _resultWindow(
                                CzechStrings.orderCancelled,
                                Colors.red.shade100,
                                errorIcon(),
                              ),
                            if (order.status == 'PENDING')
                              _resultWindow(
                                CzechStrings.orderPending,
                                Colors.blue.shade100,
                                waitingIcon(),
                              ),
                            if (role == 'customer')
                              if (order.status == 'READY')
                                _resultWindow(
                                  CzechStrings.orderReady,
                                  Colors.green.shade100,
                                  checkIcon(color: Colors.green.shade400),
                                ),
                            if (mode == 'after-creation')
                              if (order.status == 'ACTIVE')
                                _resultWindow(
                                  CzechStrings.orderRecieved,
                                  Colors.blue.shade100,
                                  checkIcon(color: Colors.blue.shade400),
                                ),

                            // if (order.status != 'ACTIVE' && role == 'customer')
                            //   Column(
                            //     children: [
                            //       SizedBox(height: 20),
                            //       Row(
                            //         mainAxisAlignment:
                            //             MainAxisAlignment.spaceEvenly,
                            //         children: [
                            //           _resultBtn('ACTIVE', 'Objednat znovu',
                            //               Icons.refresh, Colors.green, order),
                            //         ],
                            //       ),
                            //       Text(
                            //         'Na ${timeFormatter(order.pickUpTime).substring(0, 5)}',
                            //         style: TextStyle(fontSize: 18),
                            //       ),
                            //       Text(
                            //         '(Platba uloženou kartou)',
                            //         style: TextStyle(fontSize: 18),
                            //       )
                            //     ],
                            //   ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
              );
            }
          } else {
            return Loading();
          }
        });
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

  Widget _resultBtn(
      String result, String text, IconData icon, Color color, Order order) {
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
        if (result == 'ACTIVE') {
          _repeatOrder(result, order, context);
        } else {
          _answerOrder(result, order, context);
        }
      },
    );
  }
}

Widget _QrCard(Order order, UserData userData, String role) {
  return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(0, 0),
              blurRadius: 15.0,
              spreadRadius: 5.0),
        ],
      ),
      child: Column(
        children: [
          QrImage(
            data: order.orderId,
            size: 220,
          ),
          Text(
            '${CzechStrings.orderCode}: "${order.orderId.substring(0, 6).toUpperCase()}"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ));
}

Widget _fancyInfoCard(Order order, UserData userData) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(
        Radius.circular(40),
      ),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.shade300,
            offset: Offset(0, 0),
            blurRadius: 15.0,
            spreadRadius: 5.0),
      ],
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
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                order.username,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${order.price.toString()} Kč',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                '${CzechStrings.orderCode}: ${order.orderId.substring(0, 6).toUpperCase()}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Order? _getUpdatedOrder(List<Order> orderList, Order order) {
  Order? result;
  for (var item in orderList) {
    if (item.orderId == order.orderId) {
      result = item;
    }
  }
  return result;
}

// MOVE ORDER TO PASSIVE ORDERS
Future _answerOrder(String status, Order order, BuildContext context) async {
  DocumentReference _docRef = await DatabaseService().createOrder(
    status,
    order.items,
    order.price,
    order.pickUpTime,
    order.username,
    order.place,
    order.orderId,
    order.userId,
    order.day,
  );

  await DatabaseService().updateOrderId(_docRef.id, status);
  await DatabaseService().deleteOrder(order.orderId);
  Navigator.pop(context);
}

// MOVE ORDER BACK TO ACTIVE ORDERS
Future _repeatOrder(String status, Order order, BuildContext context) async {
  DocumentReference _docRef = await DatabaseService().createOrder(
    status,
    order.items,
    order.price,
    order.pickUpTime,
    order.username,
    order.place,
    '',
    order.userId,
    order.day,
  );
  await DatabaseService().updateOrderId(_docRef.id, status);

  Navigator.pop(context);
}
