import 'dart:async';

import 'package:qr_coffee/models/item.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/place.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/admin/bar_chart.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:qr_coffee/shared/custom_buttons.dart';
import 'package:qr_coffee/shared/custom_small_widgets.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/strings.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  bool show = true;

  @override
  Widget build(BuildContext context) {
    // GET CURRENTLY LOGGED USER AND DATA STREAMS
    final user = Provider.of<User?>(context);
    return StreamBuilder4<List<Order>, List<Item>, List<Place>, UserData>(
      streams: Tuple4(
        DatabaseService().passiveOrderList,
        DatabaseService().coffeeList,
        DatabaseService().placeList,
        DatabaseService(uid: user!.uid).userData,
      ),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData &&
            snapshots.item2.hasData &&
            snapshots.item3.hasData &&
            snapshots.item4.hasData) {
          List<Order> passiveOrderList = snapshots.item1.data!;
          List<Item> items = snapshots.item2.data!;
          List<Place> places = snapshots.item3.data!;
          UserData userData = snapshots.item4.data!;

          List<Order> filteredOrderList = _getFiltered(passiveOrderList);

          return Scaffold(
            appBar: customAppBar(context, title: Text(CzechStrings.stats)),
            body: Container(
              child: Column(
                children: [
                  SizedBox(height: Responsive.height(2, context)),
                  show
                      ? BarChartSample2(orders: filteredOrderList)
                      : Container(
                          height: 360,
                          child: Center(
                            child: Loading(),
                          ),
                        ),
                  CustomDivider(),
                  SizedBox(height: Responsive.height(2, context)),
                  _genButton(
                      context, items, places, 1, 'Generovat 1 objednávku'),
                  SizedBox(height: Responsive.height(1, context)),
                  _genButton(
                      context, items, places, 10, 'Generovat 10 objednávek'),
                  SizedBox(height: Responsive.height(1, context)),
                  _genButton(
                      context, items, places, 100, 'Generovat 100 objednávek'),
                  SizedBox(height: Responsive.height(2, context)),
                ],
              ),
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }

  Widget _genButton(
    context,
    List<Item> items,
    List<Place> places,
    int iterations,
    String title,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.width(0, context)),
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.check_circle,
          color: Colors.green.shade300,
        ),
        label: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            color: Colors.black,
          ),
        ),
        onPressed: () {
          _orderGenerator(items, places, iterations);
          setState(() {
            show = !show;
          });
          Timer(Duration(milliseconds: 1500), () {
            setState(() {
              show = !show;
            });
          });
        },
        style: customButtonStyle(color: Colors.grey.shade300),
      ),
    );
  }
}

List<Order> _getFiltered(List<Order> unfiltered) {
  List<Order> filtered = [];
  for (var item in unfiltered) {
    if (item.flag == 'virtual') {
      filtered.add(item);
    }
  }
  return filtered;
}

Future _orderGenerator(
  List<Item> items,
  List<Place> places,
  int iterations,
) async {
  for (var i = 1; i < iterations + 1; i++) {
    // STATE
    String state = states[0];
    if (random(1, 101) % 25 == 0) {
      state = states[1];
    }
    if (random(1, 101) % 50 == 0) {
      state = states[2];
    }

    // TIME (not considering month underflow)
    String presentTime = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

    String yyyyMM = presentTime.substring(0, 6);
    String dd = random(1, 8).toString();
    String HH = random(7, 18).toString();
    String mm = random(0, 61).toString();
    String ss = random(0, 61).toString();
    if (dd.length == 1) {
      dd = '0$dd';
    }
    if (HH.length == 1) {
      HH = '0$HH';
    }
    if (mm.length == 1) {
      mm = '0$mm';
    }
    if (ss.length == 1) {
      ss = '0$ss';
    }
    String pickUpTime = '$yyyyMM$dd$HH$mm$ss';

    List<Item> selectedItems = [];
    if (random(1, 101) % 4 == 0) {
      // 25% chance for croissant
      selectedItems.add(items[8]);
    } else {
      // 75% chance for drink
      selectedItems.add(items[random(0, 8)]);
    }
    if (random(1, 101) % 5 == 0) {
      // 20% chance for for ordering 2nd item
      selectedItems.add(items[random(0, 9)]);
    }
    if (random(1, 101) % 20 == 0) {
      // 5% chance for for ordering 3rd item
      selectedItems.add(items[random(0, 9)]);
    }
    if (random(1, 101) % 50 == 0) {
      // 2% chance for for ordering 4th item
      selectedItems.add(items[random(0, 9)]);
    }

    List<String> stringList = getStringList(selectedItems);
    int price = getTotalPrice(items, selectedItems);
    String username = names[random(0, 10)];
    String flag = 'virtual';
    String place = places[random(0, 2)].address;
    String orderId = '';
    String userId = 'ID';

    // print('\n#################ORDER#################');
    // print('state: $state');
    // print('items: $items');
    // print('price: $price Kč');
    // print('pickUpTime: ${timeFormatter(pickUpTime)}');
    // print('username: $username');
    // print('place: $place');

    // place an active order to database
    DocumentReference _docRef = await DatabaseService().createOrder('active',
        stringList, price, pickUpTime, username, place, flag, orderId, userId);

    // move order from active to passive category
    await DatabaseService().createOrder(state, stringList, price, pickUpTime,
        username, place, flag, _docRef.id, userId);

    // delete active order
    await DatabaseService().deleteOrder(_docRef.id);
  }
}

random(min, max) {
  var rn = new Random();
  return min + rn.nextInt(max - min);
}

List<String> names = [
  'Roman Dovol',
  'Martin Koiš',
  'Dagmar Bergerová',
  'Jana Kopečková',
  'Michaela Hlaváčková',
  'Drahomíra Murková',
  'Josef Pávek',
  'Růžena Pavlíková',
  'Vladislav Horný',
  'Monika Holková'
];

List<String> states = [
  'complete',
  'aborted',
  'abandoned',
];
