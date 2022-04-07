import 'package:provider/provider.dart';
import 'package:qr_coffee/screens/app_customer/customer_shop_map.dart';
import 'package:qr_coffee/screens/app_customer/my_credits.dart';
import 'package:qr_coffee/screens/app_customer/my_orders.dart';
import 'package:qr_coffee/screens/order_screens/create_order/shop_selection.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

class CustomerHomeBody extends StatefulWidget {
  const CustomerHomeBody({
    Key? key,
    required this.databaseImages,
  }) : super(key: key);

  final List<Map<String, dynamic>> databaseImages;

  @override
  _CustomerHomeBodyState createState() => _CustomerHomeBodyState();
}

class _CustomerHomeBodyState extends State<CustomerHomeBody> {
  String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now()).substring(8, 10);
  String welcome = '';
  @override
  void initState() {
    super.initState();

    if (int.parse(time) >= 10 && int.parse(time) < 18) {
      welcome = AppStringValues.goodday;
    } else if ((int.parse(time) >= 0 && int.parse(time) < 3) ||
        (int.parse(time) >= 18 && int.parse(time) <= 24)) {
      welcome = AppStringValues.goodevening;
    } else if (int.parse(time) >= 3 && int.parse(time) < 10) {
      welcome = AppStringValues.goodmorning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomPaint(
            painter: BoxShadowPainter(),
            child: ClipPath(
              clipper: MyClipper(),
              child: Container(
                height: Responsive.height(40, context) / Responsive.height(0.18, context),
                decoration: BoxDecoration(
                  color: themeProvider.themeAdditionalData().containerColor,
                  boxShadow: themeProvider.themeAdditionalData().shadow,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 23,
                      right: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppStringValues.app_name,
                            style: TextStyle(
                              color: themeProvider.themeAdditionalData().textColor,
                              fontSize: 50,
                              fontFamily: 'Galada',
                            ),
                          ),
                          Text(welcome,
                              style: TextStyle(
                                fontSize: 20,
                                color: themeProvider.themeAdditionalData().textColor,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, Responsive.height(9, context), 0, 0),
            color: themeProvider.themeData().backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _proceedToOrder(widget.databaseImages, themeProvider),
                Container(
                  color: themeProvider.themeData().backgroundColor,
                  height: Responsive.height(21, context),
                  margin: EdgeInsets.symmetric(
                    horizontal: Responsive.height(3, context),
                    vertical: Responsive.height(3, context),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _squareButton(1, widget.databaseImages, themeProvider),
                      SizedBox(width: Responsive.height(3, context)),
                      _squareButton(2, widget.databaseImages, themeProvider),
                    ],
                  ),
                ),
                //CustomOutlinedButton(function: _pushMap, label: 'Mapa')
              ],
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  _pushMap() {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => CustomerShopMap()));
  }

  Widget _squareButton(
    int type,
    List<Map<String, dynamic>> databaseImages,
    ThemeProvider themeProvider,
  ) {
    double opacity = themeProvider.isLightMode() ? 1 : 0.8;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
          image: DecorationImage(
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(opacity), BlendMode.dstATop),
            image: type == 1
                ? NetworkImage(
                    chooseUrl(databaseImages, 'pictures/customer_screen/my_orders_tile.JPG'))
                : NetworkImage(
                    chooseUrl(databaseImages, 'pictures/customer_screen/qr_token_tile.JPG')),
            fit: BoxFit.cover,
          ),
          color: themeProvider.themeData().backgroundColor,
          boxShadow: themeProvider.themeAdditionalData().shadow,
        ),
        child: InkWell(
          onTap: () async {
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => type == 1 ? MyOrders() : Credits(),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: themeProvider.themeData().backgroundColor,
                  ),
                  child: Text(
                    type == 1 ? AppStringValues.myOrders : AppStringValues.myCredits,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: themeProvider.themeAdditionalData().textColor,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _proceedToOrder(List<Map<String, dynamic>> databaseImages, ThemeProvider themeProvider) {
    double opacity = themeProvider.isLightMode() ? 1 : 0.8;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Responsive.height(3, context)),
      height: Responsive.height(21, context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
        image: DecorationImage(
          colorFilter: new ColorFilter.mode(
            Colors.black.withOpacity(opacity),
            BlendMode.dstATop,
          ),
          image: NetworkImage(
              chooseUrl(databaseImages, 'pictures/customer_screen/create_order_tile.JPG')),
          fit: BoxFit.cover,
        ),
        color: themeProvider.themeData().backgroundColor,
        boxShadow: themeProvider.themeAdditionalData().shadow,
      ),
      child: InkWell(
        onTap: () async {
          Navigator.push(
            context,
            new MaterialPageRoute(
              builder: (context) => ShopSelection(),
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
                  color: themeProvider.themeData().backgroundColor,
                ),
                child: Row(
                  children: [
                    Text(
                      AppStringValues.createOrder,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: themeProvider.themeAdditionalData().textColor,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: themeProvider.themeAdditionalData().textColor,
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
    path.quadraticBezierTo(controllPoint.dx, controllPoint.dy, endPoint.dx, endPoint.dy);
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
    path.quadraticBezierTo(controllPoint.dx, controllPoint.dy, endPoint.dx, endPoint.dy);
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
