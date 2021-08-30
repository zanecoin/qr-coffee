import 'dart:async';
import 'package:cafe_app/screens/sidebar/main_drawer.dart';
import 'package:cafe_app/screens/worker_app/worker_home_body.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:cafe_app/screens/customer_app/customer_home_body.dart';

class WorkerHome extends StatefulWidget {
  const WorkerHome({Key? key}) : super(key: key);

  @override
  _WorkerHomeState createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  late StreamSubscription subscription;
  bool isInternet = false;
  bool work = true;
  void toggleView() => setState(() => work = !work);

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
        title: Text(work ? 'OBJEDNÁVKY' : app_name),
        iconTheme: new IconThemeData(),
        elevation: 5,
      ),
      drawer: Drawer(
        child: MainDrawer(toggleView: toggleView),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                if (isInternet)
                  if (work) WorkerHomeBody(),
                if (isInternet)
                  if (!work) CustomerHomeBody(),
                if (!isInternet)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Zkontrolujte připojení k internetu ...')
                      ],
                    ),
                  ),
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

  Widget text(String string) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        string,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
