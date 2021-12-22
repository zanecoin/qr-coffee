import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/admin/admin_home.dart';
import 'package:qr_coffee/screens/order_screens/create_order.dart';
import 'package:qr_coffee/screens/worker_app/qr_fun_scanner.dart';
import 'package:qr_coffee/screens/worker_app/qr_scan_screen.dart';
import 'package:qr_coffee/screens/worker_app/worker_home_body.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';

class WorkerHome extends StatefulWidget {
  const WorkerHome({Key? key, required this.databaseImages}) : super(key: key);

  final List<Map<String, dynamic>> databaseImages;

  @override
  _WorkerHomeState createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome>
    with SingleTickerProviderStateMixin {
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
              appBar: customAppBar(context,
                  title: Text(''),
                  backArrow: false,
                  actions: [
                    _scanx(),
                    _scan(),
                    _add(widget.databaseImages),
                    _chart()
                  ]),
              body: WorkerHomeBody(
                activeOrderList: activeOrderList,
                userData: userData,
              ),
            );
          } else {
            return Container(color: Colors.white);
          }
        },
      );
    } else {
      return Container(color: Colors.white);
    }
  }

  Widget _chart() {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => AdminHome()),
      ),
      icon: Icon(CommunityMaterialIcons.chart_box_outline),
    );
  }

  Widget _add(List<Map<String, dynamic>> databaseImages) {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => CreateOrder(databaseImages: databaseImages)),
      ),
      icon: Icon(Icons.add_box_outlined),
    );
  }

  Widget _scan() {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => QRScanScreen()),
      ),
      icon: Icon(Icons.qr_code_scanner),
    );
  }

  Widget _scanx() {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => QRFunScanner()),
      ),
      icon: Icon(
        Icons.qr_code,
        color: Colors.blue,
      ),
    );
  }
}
