import 'dart:math';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/dayCell.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/common_functions.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/order_chart.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/product_chart.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/states_chart.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class RangeNotifier extends ChangeNotifier {
  double normalRangeStart = 0.0;
  double normalRangeEnd = 0.0;
  double virtualRangeStart = 0.0;
  double virtualRangeEnd = 0.0;
  bool valuesInit = false;

  void changeNormalRange(double rangeStart, double rangeEnd) {
    this.normalRangeStart = rangeStart;
    this.normalRangeEnd = rangeEnd;
    notifyListeners();
  }

  void changeVirtualRange(double rangeStart, double rangeEnd) {
    this.virtualRangeStart = rangeStart;
    this.virtualRangeEnd = rangeEnd;
    notifyListeners();
  }

  void changeInitState(bool valuesInit) {
    this.valuesInit = valuesInit;
    notifyListeners();
  }
}

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  List<Product> products = [];
  List<String> normalDates = [];
  List<String> virtualDates = [];
  List<String> normalDatesSublist = [];
  List<String> virtualDatesSublist = [];
  late String companyID;
  bool showSettings = false;
  int virtualMode = 0;
  bool refreshValue = false;
  double numOfNormalCells = 0;
  double numOfVirtualCells = 0;
  final _rangeNotifier = RangeNotifier();

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
            List<String> borderDates = ['', ''];
            products = snapshots.item3.data!;
            companyID = company.companyID;

            List<DayCell> normalCells = snapshots.item2.data!;
            normalDates = getRawDates(normalCells);
            normalCells = syncCells(normalCells, normalDates);
            numOfNormalCells = normalCells.length.toDouble();

            List<DayCell> virtualCells = snapshots.item1.data!;
            virtualDates = getRawDates(virtualCells);
            virtualCells = syncCells(virtualCells, virtualDates);
            numOfVirtualCells = virtualCells.length.toDouble();

            /// Initialize only once, [refreshValue] does not have any impact.
            if (!_rangeNotifier.valuesInit) {
              resetNormalRange();
              resetVirtualRange();
              _rangeNotifier.changeInitState(true);
            }

            if (virtualMode == 0) {
              normalCells = normalCells.sublist(
                _rangeNotifier.normalRangeStart.toInt(),
                _rangeNotifier.normalRangeEnd.toInt(),
              );
              normalDatesSublist = normalDates.sublist(
                _rangeNotifier.normalRangeStart.toInt(),
                _rangeNotifier.normalRangeEnd.toInt(),
              );
              borderDates = [
                getFormattedDates([normalDates.first]).first,
                getFormattedDates([normalDates.last]).first,
              ];
            } else if (virtualMode == 1) {
              virtualCells = virtualCells.sublist(
                _rangeNotifier.virtualRangeStart.toInt(),
                _rangeNotifier.virtualRangeEnd.toInt(),
              );
              virtualDatesSublist = virtualDates.sublist(
                _rangeNotifier.virtualRangeStart.toInt(),
                _rangeNotifier.virtualRangeEnd.toInt(),
              );
              borderDates = [
                getFormattedDates([virtualDates.first]).first,
                getFormattedDates([virtualDates.last]).first,
              ];
            }

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
                      _settings(themeProvider, borderDates),
                      const SizedBox(height: 5.0),
                      _charts(normalCells, virtualCells, normalDatesSublist, virtualDatesSublist),
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
    if ((_rangeNotifier.normalRangeStart == _rangeNotifier.normalRangeEnd) ||
        (_rangeNotifier.virtualRangeStart == _rangeNotifier.virtualRangeEnd)) {
      customSnackbar(context: context, text: AppStringValues.rangeError);
    } else {
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
  }

  resetNormalRange() {
    if (numOfNormalCells - 7 > 0) {
      _rangeNotifier.changeNormalRange(numOfNormalCells - 7, numOfNormalCells);
    } else {
      _rangeNotifier.changeNormalRange(0, numOfNormalCells);
    }
  }

  resetVirtualRange() {
    if (numOfVirtualCells - 31 > 0) {
      _rangeNotifier.changeVirtualRange(numOfVirtualCells - 31, numOfVirtualCells);
    } else {
      _rangeNotifier.changeVirtualRange(0, numOfVirtualCells);
    }
  }

  callback() {
    generateData();
  }

  Future refresh() async {
    if ((_rangeNotifier.normalRangeStart == _rangeNotifier.normalRangeEnd) ||
        (_rangeNotifier.virtualRangeStart == _rangeNotifier.virtualRangeEnd)) {
      customSnackbar(context: context, text: AppStringValues.rangeError);
    } else {
      setState(() => refreshValue = !refreshValue);
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() => refreshValue = !refreshValue);
      });
    }
  }

  Widget _charts(
    List<DayCell> normalCells,
    List<DayCell> virtualCells,
    List<String> normalDates,
    List<String> virtualDates,
  ) {
    if (refreshValue == false && virtualMode == 1) {
      return Column(
        children: [
          OrderChart(cells: virtualCells, dates: virtualDates),
          ProductChart(cells: virtualCells, products: products),
          StatesChart(cells: virtualCells),
        ],
      );
    } else if (refreshValue == false && virtualMode == 0) {
      return Column(
        children: [
          OrderChart(cells: normalCells, dates: normalDates),
          ProductChart(cells: normalCells, products: products),
          StatesChart(cells: normalCells),
        ],
      );
    } else {
      return Column();
    }
  }

  Widget _settings(ThemeProvider themeProvider, List<String> borderDates) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(18.0),
        ),
        boxShadow: themeProvider.themeAdditionalData().shadow,
        color: themeProvider.themeAdditionalData().containerColor,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => showSettings = !showSettings),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStringValues.settings,
                  style: TextStyle(
                    color: themeProvider.themeAdditionalData().textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                if (!showSettings)
                  Icon(Icons.expand_more,
                      color: themeProvider.themeAdditionalData().textColor, size: 30),
                if (showSettings)
                  Icon(Icons.expand_less,
                      color: themeProvider.themeAdditionalData().textColor, size: 30),
              ],
            ),
          ),
          if (showSettings) SizedBox(height: 15.0),
          if (showSettings) _settingButtons(themeProvider, borderDates),
        ],
      ),
    );
  }

  Widget _settingButtons(ThemeProvider themeProvider, List<String> borderDates) {
    return Column(
      children: [
        Row(
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
        SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStringValues.refreshData,
              style: TextStyle(
                color: themeProvider.themeAdditionalData().textColor,
              ),
            ),
            InkWell(
              child: Container(
                  height: 30.0,
                  width: 70.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: themeProvider.themeAdditionalData().FlBorderColor,
                  ),
                  child: Icon(Icons.refresh)),
              onTap: () => refresh(),
            )
          ],
        ),
        SizedBox(height: 15.0),
        AnimatedBuilder(
          animation: _rangeNotifier,
          builder: (_, __) => Text(
            virtualMode == 1
                ? '${getFormattedDates([
                        virtualDates[_rangeNotifier.virtualRangeStart.toInt()]
                      ]).first} - ${getFormattedDates([
                        virtualDates[_rangeNotifier.virtualRangeEnd.toInt() - 1]
                      ]).first}'
                : '${getFormattedDates([
                        normalDates[_rangeNotifier.normalRangeStart.toInt()]
                      ]).first} - ${getFormattedDates([
                        normalDates[_rangeNotifier.normalRangeEnd.toInt() - 1]
                      ]).first}',
            style: TextStyle(
              color: themeProvider.themeAdditionalData().textColor,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _rangeNotifier,
          builder: (_, __) => RangeSlider(
            values: virtualMode == 1
                ? RangeValues(_rangeNotifier.virtualRangeStart, _rangeNotifier.virtualRangeEnd)
                : RangeValues(_rangeNotifier.normalRangeStart, _rangeNotifier.normalRangeEnd),
            min: 0,
            max: virtualMode == 1 ? numOfVirtualCells : numOfNormalCells,
            divisions: virtualMode == 1 ? numOfVirtualCells.toInt() : numOfNormalCells.toInt(),
            onChanged: (value) {
              if (virtualMode == 1) {
                if (value.start == value.end && value.start == 0) {
                  _rangeNotifier.changeVirtualRange(value.start, value.end + 1);
                } else if (value.start == value.end && value.end == numOfVirtualCells) {
                  _rangeNotifier.changeVirtualRange(value.start - 1, value.end);
                } else {
                  _rangeNotifier.changeVirtualRange(value.start, value.end);
                }
              } else {
                if (value.start == value.end && value.start == 0) {
                  _rangeNotifier.changeNormalRange(value.start, value.end + 1);
                } else if (value.start == value.end && value.end == numOfNormalCells) {
                  _rangeNotifier.changeNormalRange(value.start - 1, value.end);
                } else {
                  _rangeNotifier.changeNormalRange(value.start, value.end);
                }
              }
            },
            activeColor: themeProvider.themeAdditionalData().textColor,
          ),
        ),
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
