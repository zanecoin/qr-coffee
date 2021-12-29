import 'package:qr_coffee/models/order.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:qr_coffee/shared/constants.dart';

class BarChartSample2 extends StatefulWidget {
  const BarChartSample2({
    Key? key,
    required this.orders,
    required this.virtualMode,
  }) : super(key: key);

  final List<Order> orders;
  final bool virtualMode;

  @override
  State<StatefulWidget> createState() =>
      BarChartSample2State(orders: orders, virtualMode: virtualMode);
}

class BarChartSample2State extends State<BarChartSample2> {
  BarChartSample2State({
    required this.orders,
    required this.virtualMode,
  });

  List<Order> orders;
  final bool virtualMode;

  final Color rightBarColor = Colors.red;
  final double width = 20;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  int total_price = 0;
  double max = 0;

  @override
  void initState() {
    super.initState();
    final items = _orderSumList(orders);

    total_price = items[1];
    max = items[2];
    rawBarGroups = items[0];

    showingBarGroups = rawBarGroups;
  }

  _getColor() {
    return virtualMode ? Colors.amber.shade300 : Colors.blue.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          min(Responsive.width(100, context), Responsive.height(100, context)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'Celkový příjem: ${total_price} Kč\n'
            'Počet objednávek: ${orders.length}',
            style: TextStyle(fontSize: 22),
          ),
          SizedBox(height: 38),
          Container(
            child: Expanded(
              child: BarChart(
                BarChartData(
                  maxY: max,
                  barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.grey,
                        getTooltipItem: (_a, _b, _c, _d) => null,
                      ),
                      touchCallback: (FlTouchEvent event, response) {
                        if (response == null || response.spot == null) {
                          setState(() {
                            touchedGroupIndex = -1;
                            showingBarGroups = List.of(rawBarGroups);
                          });
                          return;
                        }

                        touchedGroupIndex = response.spot!.touchedBarGroupIndex;

                        setState(() {
                          if (!event.isInterestedForInteractions) {
                            touchedGroupIndex = -1;
                            showingBarGroups = List.of(rawBarGroups);
                            return;
                          }
                          showingBarGroups = List.of(rawBarGroups);
                          if (touchedGroupIndex != -1) {
                            var sum = 0.0;
                            for (var rod in showingBarGroups[touchedGroupIndex]
                                .barRods) {
                              sum += rod.y;
                            }
                            final avg = sum /
                                showingBarGroups[touchedGroupIndex]
                                    .barRods
                                    .length;

                            showingBarGroups[touchedGroupIndex] =
                                showingBarGroups[touchedGroupIndex].copyWith(
                              barRods: showingBarGroups[touchedGroupIndex]
                                  .barRods
                                  .map((rod) {
                                return rod.copyWith(y: avg);
                              }).toList(),
                            );
                          }
                        });
                      }),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: SideTitles(showTitles: false),
                    topTitles: SideTitles(showTitles: false),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => const TextStyle(
                          color: Color(0xff7589a2),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      margin: 20,
                      getTitles: (double value) {
                        switch (value.toInt()) {
                          case 0:
                            return 'Po';
                          case 1:
                            return 'Út';
                          case 2:
                            return 'St';
                          case 3:
                            return 'Čt';
                          case 4:
                            return 'Pá';
                          case 5:
                            return 'So';
                          case 6:
                            return 'Ne';
                          default:
                            return '';
                        }
                      },
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => const TextStyle(
                          color: Color(0xff7589a2),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      margin: 8,
                      reservedSize: 35,
                      interval: 1,
                      getTitles: (value) {
                        if (value == 0) {
                          return '0';
                        } else if (value == max ~/ 4) {
                          return '${(max ~/ 4).toInt()}';
                        } else if (value == max ~/ 2) {
                          return '${(max ~/ 2).toInt()}';
                        } else if (value == max ~/ 1.33) {
                          return '${(max ~/ 1.33).toInt()}';
                        } else if (value == max) {
                          return '${max.toInt()}';
                        } else {
                          return '';
                        }
                      },
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: showingBarGroups,
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(barsSpace: 0, x: x, barRods: [
      BarChartRodData(
        y: y,
        colors: [_getColor()],
        width: width,
      ),
    ]);
  }

  List<dynamic> _orderSumList(List<Order> orders) {
    List<double> sums = [0, 0, 0, 0, 0, 0, 0];
    int total_price = 0;
    int idx = 0;
    for (var order in orders) {
      String day = order.day;
      switch (day) {
        case 'Monday':
          idx = 0;
          break;
        case 'Tueseday':
          idx = 1;
          break;
        case 'Wednesday':
          idx = 2;
          break;
        case 'Thursday':
          idx = 3;
          break;
        case 'Friday':
          idx = 4;
          break;
        case 'Saturday':
          idx = 5;
          break;
        case 'Sunday':
          idx = 6;
          break;
        default:
          idx = 0;
      }
      sums[idx] += order.price;
      total_price += order.price;
    }

    double max = sums.reduce((curr, next) => curr > next ? curr : next);

    final barGroup1 = makeGroupData(0, sums[0]);
    final barGroup2 = makeGroupData(1, sums[1]);
    final barGroup3 = makeGroupData(2, sums[2]);
    final barGroup4 = makeGroupData(3, sums[3]);
    final barGroup5 = makeGroupData(4, sums[4]);
    final barGroup6 = makeGroupData(5, sums[5]);
    final barGroup7 = makeGroupData(6, sums[6]);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];
    return [items, total_price, max];
  }
}
