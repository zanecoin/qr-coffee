import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_company/app_admin/bar_chart.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/strings.dart';

class Stats extends StatefulWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  bool show = true;
  bool virtualMode = false;
  String progress = '';

  // BACK BUTTON BEHAVIOR
  Future<bool> _onWillPop() async {
    if (show == true) {
      return true;
    } else {
      _showSnackbar();
      return false;
    }
  }

  _showSnackbar() {
    customSnackbar(context: context, text: CzechStrings.waitForIt);
  }

  @override
  Widget build(BuildContext context) {
    // GET CURRENTLY LOGGED USER AND DATA STREAMS
    final user = Provider.of<User?>(context);
    return StreamBuilder5<List<Order>, List<Order>, List<Product>, List<Shop>, UserData>(
      streams: Tuple5(
        CompanyOrderDatabase().passiveOrderList,
        CompanyOrderDatabase().virtualOrderList,
        ProductDatabase().products,
        ShopDatabase().shopList,
        UserDatabase(uid: user!.uid).userData,
      ),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData &&
            snapshots.item2.hasData &&
            snapshots.item3.hasData &&
            snapshots.item4.hasData &&
            snapshots.item5.hasData) {
          List<Order> passiveOrderList = snapshots.item1.data!;
          List<Order> virtualOrderList = snapshots.item2.data!;
          List<Product> items = snapshots.item3.data!;
          List<Shop> places = snapshots.item4.data!;
          UserData userData = snapshots.item5.data!;

          return Scaffold(
            appBar: customAppBar(
              context,
              title: Text(CzechStrings.stats),
              function: show ? null : _showSnackbar,
            ),
            body: WillPopScope(
              onWillPop: () async => _onWillPop(),
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(CzechStrings.virtualMode, style: TextStyle(fontSize: 16)),
                            animatedToggle(virtualMode, callbackVirtual),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.height(2, context)),
                      CustomDivider(indent: 20),
                      if (virtualMode)
                        Column(
                          children: [
                            SizedBox(height: Responsive.height(2, context)),
                            _genButton(context, items, places, 1, CzechStrings.generate1),
                            SizedBox(height: Responsive.height(1, context)),
                            _genButton(context, items, places, 10, CzechStrings.generate10),
                            SizedBox(height: Responsive.height(1, context)),
                            _genButton(context, items, places, 100, CzechStrings.generate100),
                            SizedBox(height: Responsive.height(2, context)),
                            CustomDivider(indent: 20),
                            SizedBox(height: Responsive.height(2, context)),
                          ],
                        ),
                      show
                          ? BarChartSample2(
                              virtualMode: virtualMode,
                              orders: virtualMode ? virtualOrderList : passiveOrderList)
                          : Container(
                              height: min(
                                  Responsive.width(100, context), Responsive.height(100, context)),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(progress),
                                  SizedBox(height: 20),
                                  Loading(
                                    color:
                                        virtualMode ? Colors.amber.shade300 : Colors.blue.shade300,
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }

  void callbackVirtual() {
    setState(() => virtualMode = !virtualMode);
    setState(() {
      show = !show;
    });
    Timer(Duration(milliseconds: 1500), () {
      setState(() {
        show = !show;
      });
    });
  }

  Widget _genButton(
    context,
    List<Product> items,
    List<Shop> places,
    int iterations,
    String title,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.width(0, context)),
      child: ElevatedButton.icon(
        icon: Icon(
          Icons.check_circle,
          color: virtualMode ? Colors.amber.shade300 : Colors.blue.shade300,
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
        },
        style: customButtonStyle(color: Colors.grey.shade200),
      ),
    );
  }

  Future _orderGenerator(
    List<Product> items,
    List<Shop> places,
    int iterations,
  ) async {
    setState(() => show = !show);
    for (var i = 1; i < iterations + 1; i++) {
      setState(() => progress = 'Generování objednávek: $i/$iterations');
      // STATE
      String status = states[0];
      if (random(1, 101) % 25 == 0) {
        status = states[1];
      }
      if (random(1, 101) % 50 == 0) {
        status = states[2];
      }

      // TIME (not considering month underflow)
      DateTime date = DateTime.now();
      String presentTime = DateFormat('yyyyMMddHHmmss').format(date);
      String day = days[random(0, 7)];

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

      List<Product> selectedItems = [];
      selectedItems.add(items[random(1, 10)]);
      if (random(1, 101) % 5 == 0) {
        // 20% chance for for ordering 2nd item
        selectedItems.add(items[random(1, 10)]);
      }
      if (random(1, 101) % 20 == 0) {
        // 5% chance for for ordering 3rd item
        selectedItems.add(items[random(1, 10)]);
      }
      if (random(1, 101) % 50 == 0) {
        // 2% chance for for ordering 4th item
        selectedItems.add(items[random(1, 10)]);
      }

      List<String> stringList = getStringList(selectedItems);
      int price = getTotalPrice(items, selectedItems);
      String username = names[random(0, 40)];
      String place = places[random(0, 2)].address;
      String orderId = '';
      String userId = 'ID';
      int triggerNum = 0;

      // print('\n#################ORDER#################');
      // print('state: $state');
      // print('items: $items');
      // print('price: $price Kč');
      // print('pickUpTime: ${timeFormatter(pickUpTime)}');
      // print('username: $username');
      // print('place: $place');

      // place virtual order to database
      DocumentReference _docRef = await CompanyOrderDatabase().createVirtualOrder(
        status,
        stringList,
        price,
        pickUpTime,
        username,
        place,
        orderId,
        userId,
        day,
        triggerNum,
      );

      await CompanyOrderDatabase().updateVirtualOrderId(_docRef.id);
    }
    setState(() => show = !show);
    setState(() => progress = '');
  }

  random(min, max) {
    var rn = new Random();
    return min + rn.nextInt(max - min);
  }
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
  'Monika Holková',
  'Olga Holubová',
  'Simona Dáňová',
  'Jan Kubita',
  'Dana Nováková',
  'Jaroslava Turečková',
  'Jiří Jozifek',
  'Martina Mitregová',
  'David Moni',
  'Ellen Kadlecová',
  'Martin Kůzl',
  'Zdeněk Pastorek',
  'David Petrák',
  'Hana Syrová',
  'Lenka Tušinovská',
  'Josef Bílek',
  'Jaromír Skalický',
  'Jan Sloboda',
  'Jiří Polák',
  'Otakar Šimonovič',
  'Rosalinda Malátová',
  'Petr Čech',
  'Milan Vondruška',
  'Ondřej Dragoun',
  'Michaela Veliká',
  'Ladislav Renda',
  'Aneta Pokorná',
  'Miroslav Škrobák',
  'Věra Tydlačková',
  'Ján Böswart',
  'Vít Kuba',
];

List<String> states = [
  'COMPLETED',
  'ABORTED',
  'ABANDONED',
];

List<String> days = [
  'Monday',
  'Tueseday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
