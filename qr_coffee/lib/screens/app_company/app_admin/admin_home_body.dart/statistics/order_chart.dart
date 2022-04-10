import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/dayCell.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/common_functions.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/common_widgets.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

class OrderChart extends StatefulWidget {
  const OrderChart({Key? key, required this.cells, required this.dates}) : super(key: key);
  final List<DayCell> cells;
  final List<String> dates;
  @override
  _OrderChartState createState() => _OrderChartState(dayCells: cells, dates: dates);
}

class _OrderChartState extends State<OrderChart> {
  _OrderChartState({required this.dayCells, required this.dates});
  final List<DayCell> dayCells;
  final List<String> dates;

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  List<Color> gradientColors2 = [
    Color.fromARGB(255, 155, 2, 211),
    Color.fromARGB(255, 230, 35, 35),
  ];

  List<FlSpot> earningSpots = [];
  List<FlSpot> amountSpots = [];
  List<String> foramttedDates = [];

  double earningScaleConst = 1;
  double amountScaleConst = 1;
  double maxEarningValue = 0;
  double maxAmountValue = 0;
  int numOfCells = 0;
  bool showMoney = true;

  _refreshValues() {
    maxEarningValue = _getMaxEarningValue(dayCells);
    maxAmountValue = _getmaxAmountValue(dayCells);
    earningScaleConst = _getScaleConst(maxEarningValue);
    amountScaleConst = _getScaleConst(maxAmountValue);
    maxEarningValue = maxEarningValue / earningScaleConst;
    maxAmountValue = maxAmountValue / amountScaleConst;
    earningSpots = _getEarningSpots(dayCells, earningScaleConst);
    amountSpots = _getAmountSpots(dayCells, amountScaleConst);
    foramttedDates = getFormattedDates(dates);
    numOfCells = dates.length;
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
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 30.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(18.0),
        ),
        boxShadow: themeProvider.themeAdditionalData().shadow,
        color: themeProvider.themeAdditionalData().containerColor,
      ),
      child: Column(
        children: [
          ChartHeader(
            text: Text(
              showMoney
                  ? '${AppStringValues.totalEarnings}: ${moneyFormatter(_getTotal(dayCells).toDouble())} ${AppStringValues.currency}'
                  : '${AppStringValues.totalAmounts}: ${moneyFormatter(_getTotal(dayCells).toDouble())}',
              style: TextStyle(
                  fontSize:
                      Responsive.isLargeDevice(context) ? 14.0 : Responsive.width(3.65, context),
                  color: textColor),
            ),
            callback: _callback,
            showMoney: showMoney,
          ),
          AspectRatio(
            aspectRatio:
                Responsive.deviceWidth(context) > Responsive.deviceHeight(context) ? 2.3 : 1.4,
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 12.0),
              child: LineChart(
                showMoney
                    ? lineChart(
                        textColor,
                        themeProvider,
                        earningSpots,
                        maxEarningValue,
                        earningScaleConst,
                        gradientColors,
                        themeProvider.themeAdditionalData().FlTouchBarColor!,
                      )
                    : lineChart(
                        textColor,
                        themeProvider,
                        amountSpots,
                        maxAmountValue,
                        amountScaleConst,
                        gradientColors2,
                        themeProvider.themeAdditionalData().FlEvilTouchBarColor!,
                      ),
                swapAnimationDuration: Duration(milliseconds: 1000),
                swapAnimationCurve: Curves.easeInOutExpo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _callback() {
    setState(() => showMoney = !showMoney);
  }

  List<FlSpot> _getEarningSpots(List<DayCell> dayCells, double scaleConst) {
    List<FlSpot> spots = [];
    double i = 0.0;
    for (DayCell cell in dayCells) {
      spots.add(FlSpot(i, cell.totalIncome.toDouble() / scaleConst));
      i++;
    }
    return spots;
  }

  List<FlSpot> _getAmountSpots(List<DayCell> dayCells, double scaleConst) {
    List<FlSpot> spots = [];
    double i = 0.0;
    for (DayCell cell in dayCells) {
      spots.add(FlSpot(i, cell.numOfOrders.toDouble() / scaleConst));
      i++;
    }
    return spots;
  }

  double _getMaxEarningValue(List<DayCell> dayCells) {
    double maxValue = 0;
    for (DayCell cell in dayCells) {
      if (cell.totalIncome > maxValue) {
        maxValue = cell.totalIncome.toDouble();
      }
    }

    return maxValue;
  }

  double _getmaxAmountValue(List<DayCell> dayCells) {
    double maxValue = 0;
    for (DayCell cell in dayCells) {
      if (cell.numOfOrders > maxValue) {
        maxValue = cell.numOfOrders.toDouble();
      }
    }

    return maxValue;
  }

  double _getScaleConst(double maxValue) {
    double scaleConst = 1;

    if (maxValue > 100 && maxValue < 1000) {
      scaleConst = 10;
    } else if (maxValue > 1000 && maxValue < 10000) {
      scaleConst = 100;
    } else if (maxValue > 10000 && maxValue < 100000) {
      scaleConst = 1000;
    } else if (maxValue > 100000 && maxValue < 1000000) {
      scaleConst = 10000;
    } else if (maxValue > 1000000 && maxValue < 10000000) {
      scaleConst = 100000;
    }

    return scaleConst;
  }

  int _getTotal(List<DayCell> dayCells) {
    int total = 0;
    for (DayCell cell in dayCells) {
      if (showMoney) {
        total += cell.totalIncome;
      } else {
        total += cell.numOfOrders;
      }
    }
    return total;
  }

  LineChartData lineChart(Color? textColor, ThemeProvider themeProvider, List<FlSpot> spots,
      double maxValue, double scaleConst, List<Color> gradColors, Color tooltipBgColor) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxValue / 5 > 0 ? maxValue / 5 : 1.0,
        verticalInterval: 1.0,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: themeProvider.themeAdditionalData().FlBorderColor,
            strokeWidth: 1.0,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          rotateAngle: -70.0,
          showTitles: true,
          reservedSize: 22.0,
          interval: 1.0,
          getTextStyles: (context, value) => TextStyle(
            color: textColor,
            fontWeight: FontWeight.normal,
            fontSize: 9.0,
          ),
          getTitles: (value) {
            bool titleCond = true;
            if (numOfCells > 10) {
              titleCond = value.toInt() % (numOfCells ~/ 10) == 0;
            }
            if (value == value.roundToDouble() && titleCond) {
              return '${foramttedDates[value.toInt()]}';
            }
            return '';
          },
          margin: 8.0,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: 1.0,
          getTextStyles: (context, value) => TextStyle(
            color: textColor,
            fontWeight: FontWeight.normal,
            fontSize: 9.0,
          ),
          getTitles: (value) {
            String thousands = '';
            double newMaxValue = (maxValue / 5).roundToDouble();
            double printValue = (10 * maxValue / 5).roundToDouble() / 10;

            if (scaleConst >= 100.0) {
              thousands = 'k';
            }
            if (scaleConst == 100.0) {
              printValue = newMaxValue / 10;
            }
            if (scaleConst == 10.0 || scaleConst == 10000.0) {
              printValue = newMaxValue * 10;
            }

            if (value == 1 * newMaxValue) {
              return '${(1 * printValue).toStringAsFixed(1)}$thousands';
            } else if (value == 2 * newMaxValue) {
              return '${(2 * printValue).toStringAsFixed(1)}$thousands';
            } else if (value == 3 * newMaxValue) {
              return '${(3 * printValue).toStringAsFixed(1)}$thousands';
            } else if (value == 4 * newMaxValue) {
              return '${(4 * printValue).toStringAsFixed(1)}$thousands';
            } else {
              return '';
            }
          },
          reservedSize: 32,
          margin: 10,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: themeProvider.themeAdditionalData().FlBorderColor!, width: 1)),
      minX: 0,
      maxX: numOfCells.toDouble() - 1,
      minY: 0,
      maxY: maxValue,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          colors: gradColors.map((color) => color.withOpacity(0.5)).toList(),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            colors: gradColors.map((color) => color.withOpacity(0.15)).toList(),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: tooltipBgColor,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;

              return LineTooltipItem(
                '${foramttedDates[flSpot.x.toInt()]} \n',
                TextStyle(
                  color: textColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text:
                        '${moneyFormatter(flSpot.y * scaleConst)} ${showMoney ? AppStringValues.currency : ''}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  // Should refresh chart values, but it does not seem to work.
  Future<dynamic> refreshState() async {
    if (!mounted) return;
    _refreshValues();
    setState(() {});
    await Future<dynamic>.delayed(Duration(milliseconds: 3000));
    await refreshState();
  }
}
