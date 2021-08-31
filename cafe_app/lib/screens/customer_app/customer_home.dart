import 'dart:async';
import 'package:cafe_app/screens/customer_app/customer_home_body.dart';
import 'package:cafe_app/screens/sidebar/main_drawer.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key}) : super(key: key);

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  late StreamSubscription subscription;
  bool isInternet = false;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          app_name,
          style: TextStyle(
              color: Colors.black, fontSize: 30, fontFamily: 'Galada'),
        ),
        iconTheme: new IconThemeData(),
        elevation: 5,
      ),
      drawer: Drawer(
        child: MainDrawer(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                if (isInternet) CustomerHomeBody(),
                if (!isInternet)
                  Center(child: Text('Zkontrolujte připojení k internetu ...')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _checkInternet() {
    subscription = InternetConnectionChecker().onStatusChange.listen(
      (status) {
        switch (status) {
          case InternetConnectionStatus.disconnected:
            setState(() => isInternet = false);
            break;
          case InternetConnectionStatus.connected:
            setState(() => isInternet = true);
            break;
        }
      },
    );
  }
}
