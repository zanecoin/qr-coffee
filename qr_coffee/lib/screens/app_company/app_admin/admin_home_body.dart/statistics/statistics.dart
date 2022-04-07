import 'dart:math';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/dayCell.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/order_chart.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/product_chart.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/states_chart.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  List<Product> products = [];
  late String companyID;

  int virtualMode = 0;

  _getBool() {
    if (virtualMode == 0) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = Provider.of<Company>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (company.companyID != '') {
      return StreamBuilder3<List<DayCell>, List<DayCell>, List<Product>>(
        streams: Tuple3(
          DayCellDatabase(companyID: company.companyID).virtualCells,
          DayCellDatabase(companyID: company.companyID).normalCells,
          ProductDatabase(companyID: company.companyID).products,
        ),
        builder: (context, snapshots) {
          if (snapshots.item1.hasData && snapshots.item2.hasData && snapshots.item3.hasData) {
            List<DayCell> virtualCells = snapshots.item1.data!.sublist(0, 364);
            List<DayCell> normalCells = snapshots.item2.data!;
            products = snapshots.item3.data!;
            companyID = company.companyID;
            return Scaffold(
              backgroundColor: themeProvider.themeData().backgroundColor,
              appBar: customAppBar(
                context,
                title: Text(
                  AppStringValues.app_name,
                  style: TextStyle(
                    fontFamily: 'Galada',
                    fontSize: 30,
                    color: themeProvider.themeAdditionalData().textColor,
                  ),
                ),
                type: 3,
              ),
              body: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(18.0),
                          ),
                          boxShadow: themeProvider.themeAdditionalData().shadow,
                          color: themeProvider.themeAdditionalData().containerColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStringValues.virtualMode,
                              style: TextStyle(
                                color: themeProvider.themeAdditionalData().textColor,
                              ),
                            ),
                            animatedToggle(_getBool(), _toggleCallback, themeProvider)
                          ],
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      if (virtualMode == 1) _charts(virtualCells),
                      if (virtualMode == 0) _charts(normalCells),
                      const SizedBox(height: 10.0),
                      //CustomOutlinedButton(function: reload, label: 'Generovat'),
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

  _toggleCallback() {
    int tempMode = 0;
    setState(() {
      tempMode = virtualMode;
      virtualMode = 2;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        if (tempMode == 0) {
          virtualMode = 1;
        } else {
          virtualMode = 0;
        }
      });
    });
  }

  callback() {
    generateData();
  }

  Future reload() async {
    setState(() {});
  }

  Widget _charts(List<DayCell> cells) {
    return Column(
      children: [
        OrderChart(cells: cells),
        ProductChart(cells: cells, products: products),
        StatesChart(cells: cells),
      ],
    );
  }

  // Function that generates random day cells spanning days specified by [dates].
  generateData() {
    List<String> dates = getDateList('1', '1', '31', '12', '2022');
    int i = 1;
    int baseOrderNum = 50;
    int baseProductNum = 5;
    int baseDispersion = 1;
    int baseDayFluctuation = 0;
    int dayFluctuation = 0;
    double seasonFluctuation = 1.0;

    for (String date in dates) {
      print(seasonFluctuation);
      int totalPrice = 0;
      int totalProducts = 0;
      if ((i + 6) % 7 == 0) {
        dayFluctuation = 2 * baseDayFluctuation;
      } else if ((i + 5) % 7 == 0) {
        dayFluctuation = 0 * baseDayFluctuation;
      } else if ((i + 4) % 7 == 0) {
        dayFluctuation = 2 * baseDayFluctuation;
      } else if ((i + 3) % 7 == 0) {
        dayFluctuation = -1 * baseDayFluctuation;
      } else if ((i + 2) % 7 == 0) {
        dayFluctuation = -2 * baseDayFluctuation;
      } else if ((i + 1) % 7 == 0) {
        dayFluctuation = 3 * baseDayFluctuation;
      } else if ((i + 0) % 7 == 0) {
        dayFluctuation = 1 * baseDayFluctuation;
      }

      int orders = random(baseOrderNum + 6 * dayFluctuation - 6 * baseDispersion,
          baseOrderNum + 6 * dayFluctuation + 6 * baseDispersion);
      orders = (orders * seasonFluctuation).toInt();

      Map<String, int> productMap = Map<String, int>();

      for (Product product in products) {
        int productNum = random(baseProductNum + dayFluctuation - baseDispersion,
            baseProductNum + dayFluctuation + baseDispersion);
        if (product.productID == 'ksKnmLfkEeh2uwKyJRsL') {
          productNum = (productNum * 1.8 * seasonFluctuation).toInt();
        }
        if (product.productID == 'Y5KWPJUhsVxGmhgkROYg') {
          productNum = (productNum * 1.3 * seasonFluctuation).toInt();
        }
        productMap[product.productID] = productNum;
        totalPrice += productNum * product.price;
        totalProducts += productNum;

        // if (productNum < 0) {
        //   print('-------------------------------ERROR-------------------------------');
        // }
      }
      Map<OrderStatus, int> stateMap = Map<OrderStatus, int>();

      stateMap[OrderStatus.completed] = 96 * orders ~/ 100;
      stateMap[OrderStatus.aborted] = 3 * orders ~/ 100;
      stateMap[OrderStatus.abandoned] = 1 * orders ~/ 100;

      // print('--------------------------------');
      // print('Date: ${date}');
      // print('Number of orders: ${orders}');
      // print('Total price: ${totalPrice}');
      // print('Product/Order ratio: ${totalProducts / orders}');
      // print('Price/Order ratio: ${totalPrice / orders}');
      // print('baseOrderNum: ${baseOrderNum}');
      // print('baseProductNum: ${baseProductNum}');
      // print('baseDispersion: ${baseDispersion}');
      // print('baseDayFluctuation: ${baseDayFluctuation}');
      // print('dayFluctuation: ${dayFluctuation}');
      // print('Product map:');
      // productMap.forEach((key, val) {
      //   print('$key: $val');
      // });
      // print('--------------------------------');

      DayCellDatabase(companyID: companyID)
          .createVirtualCell(orders, totalPrice, productMap, stateMap, date);

      baseOrderNum += 5;

      if (i % 3 == 0) {
        baseProductNum += 2;
      }
      if (i % 10 == 0) {
        baseDispersion += 1;
        baseDayFluctuation += 1;
      }
      i += 1;

      if (i < 90 || (i >= 180 && i < 270)) {
        seasonFluctuation *= 1.01;
      } else if ((i >= 90 && i < 180) || (i >= 270)) {
        seasonFluctuation *= 0.99;
      }
    }
  }

  random(min, max) {
    var rn = new Random();
    return min + rn.nextInt(max - min);
  }
}
