import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/dayCell.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/common_widgets.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

class ProductChart extends StatefulWidget {
  const ProductChart({Key? key, required this.cells, required this.products}) : super(key: key);
  final List<DayCell> cells;
  final List<Product> products;
  final List<Color> availableColors = const [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];

  @override
  State<StatefulWidget> createState() => _ProductChartState(dayCells: cells, products: products);
}

class _ProductChartState extends State<ProductChart> {
  _ProductChartState({required this.dayCells, required this.products});
  final List<DayCell> dayCells;
  final List<Product> products;
  bool showMoney = false;

  final Color barBackgroundColor = const Color(0xff23b6e6).withOpacity(0.15);
  final Color barForegroundColor = const Color(0xff02d39a).withOpacity(0.1);
  final Color onTouchColor = const Color(0xffffeb3b).withOpacity(0.15);

  int touchedIndex = -1;

  List<double> productAmounts = [];
  List<double> productEarnings = [];

  _refreshValues() {
    productAmounts = _getProuductAmounts();
    productEarnings = _getProuductEarnings();
  }

  @override
  void initState() {
    super.initState();
    _refreshValues();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final Color? textColor = themeProvider.themeAdditionalData().textColor;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 25.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(18.0),
        ),
        boxShadow: themeProvider.themeAdditionalData().shadow,
        color: themeProvider.themeAdditionalData().containerColor,
      ),
      child: AspectRatio(
        aspectRatio: Responsive.isLargeDevice(context) ? 1.8 : 1.1,
        child: Column(
          children: <Widget>[
            ChartHeader(
                text: Text(
                  showMoney ? AppStringValues.productEarnings : AppStringValues.productAmounts,
                  style: TextStyle(
                    fontSize:
                        Responsive.isLargeDevice(context) ? 14.0 : Responsive.width(3.45, context),
                    color: textColor,
                  ),
                ),
                callback: _callback,
                showMoney: showMoney),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: BarChart(
                  showMoney
                      ? barChart(textColor, themeProvider, productEarnings)
                      : barChart(textColor, themeProvider, productAmounts),
                  swapAnimationDuration: Duration(milliseconds: 500),
                  //swapAnimationCurve: Curves.easeInOutExpo, // bugs highlighting
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  _callback() {
    setState(() => showMoney = !showMoney);
  }

  List<double> _getProuductAmounts() {
    List<double> productAmounts = [];
    for (Product product in products) {
      int amount = 0;
      for (DayCell cell in dayCells) {
        if (cell.items[product.productID] != null) {
          int additive = cell.items[product.productID];
          amount = amount + additive;
        }
      }

      productAmounts.add(amount.toDouble());
    }
    return productAmounts;
  }

  List<double> _getProuductEarnings() {
    List<double> productEarnings = [];
    for (Product product in products) {
      int amount = 0;
      for (DayCell cell in dayCells) {
        if (cell.items[product.productID] != null) {
          int additive = cell.items[product.productID];
          amount = amount + additive * product.price;
        }
      }

      productEarnings.add(amount.toDouble());
    }
    return productEarnings;
  }

  BarChartGroupData makeGroupData(
    int x,
    double y,
    List<double> amounts, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 20,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y : y,
          colors: isTouched ? [onTouchColor] : [barForegroundColor],
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.yellow, width: 1)
              : BorderSide(color: Color(0xff02d39a).withOpacity(0.25), width: 2),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: amounts.reduce(max),
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups(List<double> amounts) => List.generate(
        11,
        (i) {
          switch (i) {
            case 0:
              return makeGroupData(0, amounts[0], amounts, isTouched: i == touchedIndex);
            case 1:
              return makeGroupData(1, amounts[1], amounts, isTouched: i == touchedIndex);
            case 2:
              return makeGroupData(2, amounts[2], amounts, isTouched: i == touchedIndex);
            case 3:
              return makeGroupData(3, amounts[3], amounts, isTouched: i == touchedIndex);
            case 4:
              return makeGroupData(4, amounts[4], amounts, isTouched: i == touchedIndex);
            case 5:
              return makeGroupData(5, amounts[5], amounts, isTouched: i == touchedIndex);
            case 6:
              return makeGroupData(6, amounts[6], amounts, isTouched: i == touchedIndex);
            case 7:
              return makeGroupData(7, amounts[7], amounts, isTouched: i == touchedIndex);
            case 8:
              return makeGroupData(8, amounts[8], amounts, isTouched: i == touchedIndex);
            case 9:
              return makeGroupData(9, amounts[9], amounts, isTouched: i == touchedIndex);
            case 10:
              return makeGroupData(10, amounts[10], amounts, isTouched: i == touchedIndex);
            default:
              return throw Error();
          }
        },
      );

  BarChartData barChart(
    Color? textColor,
    ThemeProvider themeProvider,
    List<double> amounts,
  ) {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: themeProvider.themeAdditionalData().FlTouchBarColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String product;
              switch (group.x.toInt()) {
                case 0:
                  product = products[0].name;
                  break;
                case 1:
                  product = products[1].name;
                  break;
                case 2:
                  product = products[2].name;
                  break;
                case 3:
                  product = products[3].name;
                  break;
                case 4:
                  product = products[4].name;
                  break;
                case 5:
                  product = products[5].name;
                  break;
                case 6:
                  product = products[6].name;
                  break;
                case 7:
                  product = products[7].name;
                  break;
                case 8:
                  product = products[8].name;
                  break;
                case 9:
                  product = products[9].name;
                  break;
                case 10:
                  product = products[10].name;
                  break;
                default:
                  throw Error();
              }
              return BarTooltipItem(
                product + '\n',
                TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '${moneyFormatter(rod.y)} ${showMoney ? AppStringValues.currency : 'ks'}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          rotateAngle: -90,
          showTitles: true,
          getTextStyles: (context, value) =>
              TextStyle(color: textColor, fontWeight: FontWeight.normal, fontSize: 10),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return products[0].name;
              case 1:
                return products[1].name;
              case 2:
                return products[2].name;
              case 3:
                return products[3].name;
              case 4:
                return products[4].name;
              case 5:
                return products[5].name;
              case 6:
                return products[6].name;
              case 7:
                return products[7].name;
              case 8:
                return products[8].name;
              case 9:
                return products[9].name;
              case 10:
                return products[10].name;
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(showTitles: false),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingGroups(amounts),
      gridData: FlGridData(show: false),
    );
  }
}
