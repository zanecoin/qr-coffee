import 'package:flutter/material.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';

class FancyInfoCard extends StatelessWidget {
  const FancyInfoCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = Responsive.deviceWidth(context);
    final bool largeDevice =
        deviceWidth > kDeviceUpperWidthTreshold ? true : false;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      width: deviceWidth > kDeviceUpperWidthTreshold
          ? Responsive.width(50, context)
          : null,
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
                  largeDevice
                      ? (order.username.length < 400 ~/ 17
                          ? '${order.username}'
                          : '${order.username.substring(0, 400 ~/ 17)}...')
                      : (order.username.length <
                              Responsive.textTresholdShort(context)
                          ? '${order.username}'
                          : '${order.username.substring(0, Responsive.textTresholdShort(context))}...'),
                  style: TextStyle(
                    fontSize: 23,
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
}
