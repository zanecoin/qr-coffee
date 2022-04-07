import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/models/user.dart';
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

  @override
  Widget build(BuildContext context) {
    final userFromAuth = Provider.of<UserFromAuth?>(context);
    final company = Provider.of<Company>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (company.companyID != '') {
      return StreamBuilder4<List<Order>, List<Order>, List<Product>, List<Shop>>(
        streams: Tuple4(
          CompanyOrderDatabase(companyID: company.companyID).passiveOrderList,
          CompanyOrderDatabase(companyID: company.companyID).virtualOrderList,
          ProductDatabase(companyID: company.companyID).products,
          ShopDatabase(companyID: company.companyID).shopList,
        ),
        builder: (context, snapshots) {
          if (snapshots.item1.hasData &&
              snapshots.item2.hasData &&
              snapshots.item3.hasData &&
              snapshots.item4.hasData) {
            List<Order> passiveOrderList = snapshots.item1.data!;
            List<Order> virtualOrderList = snapshots.item2.data!;
            List<Product> items = snapshots.item3.data!;
            List<Shop> places = snapshots.item4.data!;

            return Scaffold(
              appBar: customAppBar(
                context,
                title: Text(
                  AppStringValues.app_name,
                  style: TextStyle(fontFamily: 'Galada', fontSize: 30),
                ),
                type: 3,
              ),
              body: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppStringValues.virtualMode, style: TextStyle(fontSize: 16)),
                            animatedToggle(virtualMode, callbackVirtual, themeProvider),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.height(2, context)),
                      CustomDivider(indent: 20),
                      if (virtualMode)
                        Column(
                          children: [
                            SizedBox(height: Responsive.height(2, context)),
                            _genButton(context, items, places, 1, AppStringValues.generate1),
                            SizedBox(height: Responsive.height(1, context)),
                            _genButton(context, items, places, 10, AppStringValues.generate10),
                            SizedBox(height: Responsive.height(1, context)),
                            _genButton(context, items, places, 100, AppStringValues.generate100),
                            SizedBox(height: Responsive.height(2, context)),
                            CustomDivider(indent: 20),
                            SizedBox(height: Responsive.height(2, context)),
                          ],
                        ),
                    ],
                  ),
                ),
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

  Widget _genButton(context, List<Product> items, List<Shop> places, int iterations, String title) {
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
      OrderStatus status = states[0];
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
        // 20% chance for for ordering 2nd item.
        selectedItems.add(items[random(1, 10)]);
      }
      if (random(1, 101) % 20 == 0) {
        // 5% chance for for ordering 3rd item.
        selectedItems.add(items[random(1, 10)]);
      }
      if (random(1, 101) % 50 == 0) {
        // 2% chance for for ordering 4th item.
        selectedItems.add(items[random(1, 10)]);
      }

      Map<String, String> stringList = getStringList(selectedItems);
      int price = getTotalPrice(items, selectedItems);
      String username = names[random(0, 40)];
      String shop = 'Ulice 666';
      String orderID = 'ID';
      String userID = 'ID';
      String shopID = 'ID';
      String companyID = 'ID';
      String company = 'QR Coffee';

      // print('\n#################ORDER#################');
      // print('state: $state');
      // print('items: $items');
      // print('price: $price Kč');
      // print('pickUpTime: ${timeFormatter(pickUpTime)}');
      // print('username: $username');
      // print('place: $place');

      // Place virtual order to database.
      DocumentReference _docRef =
          await CompanyOrderDatabase(companyID: companyID).createVirtualOrder(
        status,
        stringList,
        price,
        pickUpTime,
        username,
        shop,
        company,
        orderID,
        userID,
        shopID,
        companyID,
        day,
      );

      await CompanyOrderDatabase(companyID: companyID).updateVirtualorderID(_docRef.id);
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

List<OrderStatus> states = [
  OrderStatus.completed,
  OrderStatus.aborted,
  OrderStatus.abandoned,
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
