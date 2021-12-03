import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/admin/admin_home.dart';
import 'package:qr_coffee/screens/order_screens/set_order_frame.dart';
import 'package:qr_coffee/screens/worker_app/worker_home_body.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:qr_coffee/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';

class WorkerHome extends StatefulWidget {
  const WorkerHome({Key? key}) : super(key: key);

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
                  actions: [_scan(), _add(), _chart()]),
              body: WorkerHomeBody(
                activeOrderList: activeOrderList,
                userData: userData,
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

  Widget _chart() {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => AdminHome()),
      ),
      icon: Icon(CommunityMaterialIcons.chart_box_outline),
    );
  }

  Widget _add() {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => SetOrderFrame()),
      ),
      icon: Icon(Icons.add_box_outlined),
    );
  }

  Widget _scan() {
    return IconButton(
      onPressed: () {},
      icon: Icon(Icons.qr_code_scanner),
    );
  }
}

// AppBar(
//                 //leading:
//                 title: Text(''),
//                 centerTitle: true,
//                 elevation: 0,

//                 backgroundColor: Colors.transparent,
//                 actions: [_add(), _chart()],
//               ),