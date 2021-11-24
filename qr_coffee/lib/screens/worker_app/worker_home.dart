import 'dart:async';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/admin/admin_home.dart';
import 'package:qr_coffee/screens/sidebar/main_drawer.dart';
import 'package:qr_coffee/screens/worker_app/worker_home_body.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/loading.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:qr_coffee/screens/customer_app/customer_home_body.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';

class WorkerHome extends StatefulWidget {
  const WorkerHome({Key? key}) : super(key: key);

  @override
  _WorkerHomeState createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome>
    with SingleTickerProviderStateMixin {
  late StreamSubscription subscription;
  late TabController controller;
  bool isInternet = false;
  bool worker = true;
  List<String> choices = [
    CzechStrings.adminmode,
    CzechStrings.workmode,
    CzechStrings.usermode,
  ];

  @override
  void initState() {
    super.initState();
    _checkInternet();
    controller = TabController(length: choices.length, vsync: this);
    controller.addListener(() {
      setState(() {
        worker = !worker;
      });
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // GET CURRENTLY LOGGED USER AND DATA STREAMS
    final user = Provider.of<User?>(context);
    if (user != null) {
      return StreamBuilder2<UserData, List<Order>>(
        streams: Tuple2(DatabaseService(uid: user.uid).userData,
            DatabaseService().activeOrderList),
        builder: (context, snapshots) {
          if (snapshots.item1.hasData && snapshots.item2.hasData) {
            UserData userData = snapshots.item1.data!;
            List<Order> activeOrderList = snapshots.item2.data!;
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  CzechStrings.app_name,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontFamily: 'Galada',
                  ),
                ),
                iconTheme: new IconThemeData(),
                elevation: 5,
                bottom: TabBar(
                  controller: controller,
                  labelPadding: EdgeInsets.symmetric(vertical: 0),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey.shade800,
                  indicatorColor: controller.index == 0
                      ? Colors.green.shade300
                      : Colors.blue.shade300,
                  tabs: choices
                      .map<Widget>((choice) => Tab(text: choice))
                      .toList(),
                ),
              ),
              drawer: Drawer(
                child: MainDrawer(),
              ),
              body: TabBarView(
                controller: controller,
                children: choices
                    .map((choice) =>
                        _screenChooser(choice, activeOrderList, userData))
                    .toList(),
              ),
            );
          } else {
            return Loading();
          }
        },
      );
    } else {
      return Loading();
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

  Widget _screenChooser(
    String title,
    List<Order> activeOrderList,
    UserData userData,
  ) {
    Widget result = WorkerHomeBody(
      activeOrderList: activeOrderList,
      userData: userData,
    );
    if (isInternet) {
      switch (title) {
        case CzechStrings.workmode:
          result = WorkerHomeBody(
            activeOrderList: activeOrderList,
            userData: userData,
          );
          break;
        case CzechStrings.usermode:
          result = CustomerHomeBody();
          break;
        case CzechStrings.adminmode:
          result = AdminHome();
          break;
      }
    } else {
      result = LoadingInternet();
    }
    return result;
  }
}
