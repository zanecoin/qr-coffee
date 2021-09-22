import 'dart:async';
import 'package:cafe_app/models/order.dart';
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/screens/sidebar/main_drawer.dart';
import 'package:cafe_app/screens/worker_app/worker_home_body.dart';
import 'package:cafe_app/service/database.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:cafe_app/shared/loading.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:cafe_app/screens/customer_app/customer_home_body.dart';
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
  List<String> choices = ['Pracovní mód', 'Uživatelský mód'];

  @override
  void initState() {
    super.initState();
    _checkInternet();
    controller = TabController(length: 2, vsync: this);
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
    // get currently logged user and theme provider
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
                title: controller.index == 0 ? _textB() : _textA(),
                iconTheme: new IconThemeData(),
                elevation: 5,
                bottom: TabBar(
                  controller: controller,
                  labelPadding: EdgeInsets.symmetric(vertical: 0),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: choices
                      .map<Widget>(
                        (choice) => Tab(
                          text: choice,
                        ),
                      )
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

  Widget _textA() {
    return Text(
      app_name,
      style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: 'Galada'),
    );
  }

  Widget _textB() {
    return Text('OBJEDNÁVKY');
  }

  Widget _screenChooser(
      String title, List<Order> activeOrderList, UserData userData) {
    Widget result = WorkerHomeBody(
      activeOrderList: activeOrderList,
      userData: userData,
    );
    if (isInternet) {
      switch (title) {
        case 'Pracovní mód':
          result = WorkerHomeBody(
            activeOrderList: activeOrderList,
            userData: userData,
          );
          break;
        case 'Uživatelský mód':
          result = CustomerHomeBody();
      }
    } else {
      result = LoadingInternet();
    }
    return result;
  }
}
