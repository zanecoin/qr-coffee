import 'package:provider/provider.dart';
import 'package:qr_coffee/screens/app_customer/customer_home_body.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key, required this.databaseImages}) : super(key: key);

  final List<Map<String, dynamic>> databaseImages;

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.themeData().backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: customAppBar(
        context,
        title: Text(''),
        type: 2,
        color: themeProvider.themeData().backgroundColor,
      ),
      body: CustomerHomeBody(databaseImages: widget.databaseImages),
    );
  }
}
