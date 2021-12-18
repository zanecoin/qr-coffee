import 'dart:async';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/customer_app/my_orders.dart';
import 'package:qr_coffee/screens/customer_app/qr_tokens.dart';
import 'package:qr_coffee/screens/order_screens/create_order.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
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
    // GET CURRENTLY LOGGED USER, DATA STREAMS AND LOAD PICTURES FROM DATABASE
    final user = Provider.of<User?>(context);
    return FutureBuilder(
        future: loadImages('pictures/'),
        builder:
            (context, AsyncSnapshot<List<Map<String, dynamic>>> picSnapshot) {
          return StreamBuilder<UserData>(
            stream: DatabaseService(uid: user!.uid).userData,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  picSnapshot.connectionState == ConnectionState.done) {
                UserData userData = snapshot.data!;
                List<Map<String, dynamic>> databaseImages = picSnapshot.data!;
                String time = DateFormat('yyyyMMddHHmmss')
                    .format(DateTime.now())
                    .substring(8, 10);

                String welcome = '';
                if (int.parse(time) >= 10 && int.parse(time) < 18) {
                  welcome = CzechStrings.goodday;
                } else if ((int.parse(time) >= 0 && int.parse(time) < 3) ||
                    (int.parse(time) >= 18 && int.parse(time) <= 24)) {
                  welcome = CzechStrings.goodevening;
                } else if (int.parse(time) >= 3 && int.parse(time) < 10) {
                  welcome = CzechStrings.goodmorning;
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomPaint(
                        painter: BoxShadowPainter(),
                        child: ClipPath(
                          clipper: MyClipper(),
                          child: Container(
                            height: 220,
                            width: Responsive.width(100, context),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white,
                                ],
                                begin: Alignment.bottomRight,
                                end: Alignment.topLeft,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(1, 1),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 30,
                                  right: 30,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CzechStrings.app_name,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 60,
                                          fontFamily: 'Galada',
                                        ),
                                      ),
                                      Text(welcome,
                                          style: TextStyle(fontSize: 20)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 70, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _proceedToOrder(userData, databaseImages),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _squareButton(1, databaseImages),
                                  _squareButton(2, databaseImages),
                                ],
                              ),
                            )
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
        });
  }

  Widget _squareButton(int type, List<Map<String, dynamic>> databaseImages) {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
        image: DecorationImage(
          colorFilter: new ColorFilter.mode(
            Colors.black.withOpacity(1),
            BlendMode.dstATop,
          ),
          image: type == 1
              ? NetworkImage(
                  chooseUrl(databaseImages, 'pictures/my_orders_tile.JPG'))
              : NetworkImage(
                  chooseUrl(databaseImages, 'pictures/qr_token_tile.JPG')),
          fit: BoxFit.cover,
        ),
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
        onTap: () async {
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => type == 1 ? MyOrders() : QRTokens(),
            ),
          );
        },
        child: Stack(
          children: [
            Positioned(
              bottom: 10,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: Text(
                  type == 1 ? CzechStrings.myOrders : CzechStrings.myTokens,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _proceedToOrder(
      UserData userData, List<Map<String, dynamic>> databaseImages) {
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
          image: NetworkImage(
              chooseUrl(databaseImages, 'pictures/create_order_tile.JPG')),
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
        onTap: () async {
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => CreateOrder(databaseImages: databaseImages),
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

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0, size.height - 70);
    var controllPoint = Offset(10, size.height);
    var endPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(
        controllPoint.dx, controllPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class BoxShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    // here are my custom shapes
    path.lineTo(0, size.height - 70);
    var controllPoint = Offset(10, size.height);
    var endPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(
        controllPoint.dx, controllPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawShadow(path, Colors.black45, 20.0, false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
