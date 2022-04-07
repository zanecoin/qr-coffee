import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/dayCell.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/common_widgets.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

class OrderChart extends StatefulWidget {
  const OrderChart({Key? key, required this.cells}) : super(key: key);
  final List<DayCell> cells;
  @override
  _OrderChartState createState() => _OrderChartState(dayCells: cells);
}

class _OrderChartState extends State<OrderChart> {
  _OrderChartState({required this.dayCells});
  final List<DayCell> dayCells;

  List<Color> gradientColors = [const Color(0xff23b6e6), const Color(0xff02d39a)];

  List<FlSpot> earningSpots = [];
  List<FlSpot> amountSpots = [];
  List<String> dates = [];
  List<DayCell> syncedCells = [];
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
    dates = _getRawDates(dayCells);
    syncedCells = _syncCells(dayCells, dates);
    earningSpots = _getEarningSpots(syncedCells, earningScaleConst);
    amountSpots = _getAmountSpots(syncedCells, amountScaleConst);
    dates = _getFormattedDates(dates);
    numOfCells = dates.length;
    print(maxAmountValue);
  }

  @override
  void initState() {
    super.initState();
    _refreshValues();
    refreshState();
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
                  fontSize: Responsive.deviceWidth(context) > kDeviceUpperWidthTreshold
                      ? 14.0
                      : Responsive.width(3.65, context),
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
                      )
                    : lineChart(
                        textColor,
                        themeProvider,
                        amountSpots,
                        maxAmountValue,
                        amountScaleConst,
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

  List<String> _getRawDates(List<DayCell> dayCells) {
    String firstDay = dayCells[0].date;
    String lastDay = dayCells.last.date;
    List<String> dates = getDateList(
      firstDay.substring(8, 10),
      firstDay.substring(5, 7),
      lastDay.substring(8, 10),
      lastDay.substring(5, 7),
      firstDay.substring(0, 4),
    );

    return dates;
  }

  List<String> _getFormattedDates(List<String> dates) {
    for (int i = 0; i < dates.length; i++) {
      dates[i] = '${dates[i].substring(8, 10)}. ${dates[i].substring(5, 7)}. ';
    }

    return dates;
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

    if (maxValue > 1000) {
      scaleConst = 1000;
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

  List<DayCell> _syncCells(List<DayCell> dayCells, List<String> dates) {
    List<DayCell> syncedCells = [];
    bool included;
    DayCell includedCell = DayCell.initialData();

    for (String date in dates) {
      included = false;
      for (DayCell dayCell in dayCells) {
        if (date == dayCell.date) {
          included = true;
          includedCell = dayCell;
        }
      }
      if (included) {
        syncedCells.add(includedCell);
      } else {
        syncedCells.add(DayCell.initialData());
      }
    }

    return syncedCells;
  }

  LineChartData lineChart(Color? textColor, ThemeProvider themeProvider, List<FlSpot> spots,
      double maxValue, double scaleConst) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxValue / 5,
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
              return '${dates[value.toInt()]}';
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
            if (scaleConst == 1.0) {
              if (value == 1 * maxValue ~/ 5) {
                return '${1 * maxValue ~/ 5}';
              } else if (value == 2 * maxValue ~/ 5) {
                return '${2 * maxValue ~/ 5}';
              } else if (value == 3 * maxValue ~/ 5) {
                return '${3 * maxValue ~/ 5}';
              } else if (value == 4 * maxValue ~/ 5) {
                return '${4 * maxValue ~/ 5}';
              } else {
                return '';
              }
            } else {
              if ((value * scaleConst).toInt() ==
                  (1 * maxValue * scaleConst / 5000).round() * 1000) {
                return '${(1 * maxValue * scaleConst / 5000).toStringAsFixed(1)}k';
              } else if ((value * scaleConst).toInt() ==
                  (2 * maxValue * scaleConst / 5000).round() * 1000) {
                return '${(2 * maxValue * scaleConst / 5000).toStringAsFixed(1)}k';
              } else if ((value * scaleConst).toInt() ==
                  (3 * maxValue * scaleConst / 5000).round() * 1000) {
                return '${(3 * maxValue * scaleConst / 5000).toStringAsFixed(1)}k';
              } else if ((value * scaleConst).toInt() ==
                  (4 * maxValue * scaleConst / 5000).round() * 1000) {
                return '${(4 * maxValue * scaleConst / 5000).toStringAsFixed(1)}k';
              } else {
                return '';
              }
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
          colors: gradientColors.map((color) => color.withOpacity(0.5)).toList(),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            colors: gradientColors.map((color) => color.withOpacity(0.15)).toList(),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: themeProvider.themeAdditionalData().FlTouchBarColor,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;

              return LineTooltipItem(
                '${dates[flSpot.x.toInt()]} \n',
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

  Future<dynamic> refreshState() async {
    if (!mounted) return;
    _refreshValues();
    setState(() {});
    await Future<dynamic>.delayed(Duration(milliseconds: 3000));
    await refreshState();
  }
}
