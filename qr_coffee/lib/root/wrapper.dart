import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home.dart';
import 'package:qr_coffee/screens/app_customer/customer_home.dart';
import 'package:qr_coffee/screens/app_company/app_worker/worker_home.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/authenticate/authenticate.dart';
import 'package:qr_coffee/service/database_service/user_database.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';
import 'package:provider/provider.dart';

// CHECKS INTERNET CONNECTION AND DECIDES BEETWEEN WORKER AND CUSTOMER SCREEN
class Wrapper extends StatefulWidget {
  const Wrapper({Key? key, required this.databaseImages}) : super(key: key);

  final List<Map<String, dynamic>> databaseImages;

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  late StreamSubscription subscription;

  bool isInternet = true;

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
    final user = Provider.of<User?>(context);

    if (isInternet || !isInternet) {
      // TODO
      // Return either Home or Auth widget.
      if (user == null || user.uid == '') {
        return Authenticate();
      } else {
        return StreamBuilder<UserData>(
          stream: UserDatabase(uid: user.uid).userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserData userData = snapshot.data!;

              if (userData.role == 'worker') {
                return WorkerHome(databaseImages: widget.databaseImages);
              } else if (userData.role == 'admin') {
                return AdminHome(databaseImages: widget.databaseImages);
              } else {
                return CustomerHome(databaseImages: widget.databaseImages);
              }
            } else {
              return Container(color: Colors.white);
            }
          },
        );
      }
    } else {
      return Scaffold(body: LoadingInternet());
    }
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
