import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_coffee/models/item.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/place.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/admin/bar_chart.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:qr_coffee/shared/widgets/custom_button_style.dart';
import 'package:qr_coffee/shared/widgets/custom_divider.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';
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

          return Scaffold(
            appBar: customAppBar(context, title: Text(CzechStrings.stats)),
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    SizedBox(height: Responsive.height(2, context)),
                    show
                        ? BarChartSample2(orders: passiveOrderList)
                        : Center(
                            child: Loading(),
                          ),
                    CustomDivider(),
                    SizedBox(height: Responsive.height(2, context)),
                    _genButton(
                        context, items, places, 1, 'Generovat 1 objednávku'),
                    SizedBox(height: Responsive.height(1, context)),
                    _genButton(
                        context, items, places, 10, 'Generovat 10 objednávek'),
                    SizedBox(height: Responsive.height(1, context)),
                    _genButton(context, items, places, 100,
                        'Generovat 100 objednávek'),
                    SizedBox(height: Responsive.height(2, context)),
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
        style: customButtonStyle(color: Colors.grey.shade200),
      ),
    );
  }
}

Future _orderGenerator(
  List<Item> items,
  List<Place> places,
  int iterations,
) async {
  for (var i = 1; i < iterations + 1; i++) {
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
    String day = days[random(0, 6)];

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

    // print('\n#################ORDER#################');
    // print('state: $state');
    // print('items: $items');
    // print('price: $price Kč');
    // print('pickUpTime: ${timeFormatter(pickUpTime)}');
    // print('username: $username');
    // print('place: $place');

    // place virtual order to database
    DocumentReference _docRef = await DatabaseService().createVirtualOrder(
      status,
      stringList,
      price,
      pickUpTime,
      username,
      place,
      orderId,
      userId,
      day,
    );

    await DatabaseService().updateVirtualOrderId(_docRef.id);
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
