import 'package:flutter/services.dart';
import 'package:qr_coffee/screens/customer_app/customer_home_body.dart';
import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:flutter/material.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key, required this.databaseImages})
      : super(key: key);

  final List<Map<String, dynamic>> databaseImages;

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: customAppBar(context, title: Text(''), backArrow: false),
      body: CustomerHomeBody(databaseImages: widget.databaseImages),
    );
  }
}
