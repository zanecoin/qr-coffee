import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/dayCell.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/service/database_service/common_functions.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

class StatesChart extends StatefulWidget {
  const StatesChart({Key? key, required this.cells}) : super(key: key);
  final List<DayCell> cells;

  @override
  State<StatefulWidget> createState() => _StatesChartState(dayCells: cells);
}

class _StatesChartState extends State {
  _StatesChartState({required this.dayCells});
  final List<DayCell> dayCells;

  int touchedIndex = -1;

  final Color completedColor = const Color(0xff02d39a).withOpacity(0.25);
  final Color abortedColor = Color.fromARGB(255, 230, 35, 35).withOpacity(0.35);
  final Color abandonedColor = Color.fromARGB(255, 230, 162, 35).withOpacity(0.35);

  List<double> productAmounts = [];

  _refreshValues() {
    productAmounts = _getStatesAmounts(dayCells);
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
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(const Radius.circular(18.0)),
        boxShadow: themeProvider.themeAdditionalData().shadow,
        color: themeProvider.themeAdditionalData().containerColor,
      ),
      child: Column(
        children: [
          Text(
            AppStringValues.orderEndingState,
            style: TextStyle(color: themeProvider.themeAdditionalData().textColor, fontSize: 16.0),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: AspectRatio(
                  aspectRatio: Responsive.isLargeDevice(context) ? 1.8 : 1.0,
                  child: PieChart(
                    PieChartData(
                        pieTouchData:
                            PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        }),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2.0,
                        centerSpaceRadius:
                            Responsive.height(1.0, context) * Responsive.width(1.0, context), //40,
                        sections: showingSections(textColor)),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Container(color: completedColor, height: 10, width: 10),
                      const SizedBox(width: 4),
                      Text(AppStringValues.picked,
                          style: TextStyle(color: textColor, fontSize: 12.0)),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Container(color: abandonedColor, height: 10, width: 10),
                      const SizedBox(width: 4),
                      Text(AppStringValues.unpicked,
                          style: TextStyle(color: textColor, fontSize: 12.0)),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Container(color: abortedColor, height: 10, width: 10),
                      const SizedBox(width: 4),
                      Text(AppStringValues.aborted,
                          style: TextStyle(color: textColor, fontSize: 12.0)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 28.0),
            ],
          ),
        ],
      ),
    );
  }

  List<double> _getStatesAmounts(List<DayCell> dayCells) {
    List<double> values = [0, 0, 0];
    for (DayCell cell in dayCells) {
      int completed = 0;
      int abandoned = 0;
      int aborted = 0;
      if (cell.states[CommonDatabaseFunctions().getStrStatus(OrderStatus.completed)] != null) {
        completed = cell.states[CommonDatabaseFunctions().getStrStatus(OrderStatus.completed)];
      }
      if (cell.states[CommonDatabaseFunctions().getStrStatus(OrderStatus.abandoned)] != null) {
        abandoned = cell.states[CommonDatabaseFunctions().getStrStatus(OrderStatus.abandoned)];
      }
      if (cell.states[CommonDatabaseFunctions().getStrStatus(OrderStatus.aborted)] != null) {
        aborted = cell.states[CommonDatabaseFunctions().getStrStatus(OrderStatus.aborted)];
      }
      values[0] += completed.toDouble();
      values[1] += abandoned.toDouble();
      values[2] += aborted.toDouble();
    }

    return values;
  }

  List<PieChartSectionData> showingSections(Color? textColor) {
    List<double> values = productAmounts;

    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 18.0 : 10.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: completedColor,
            value: values[0],
            title: '${(values[0] / values.fold(0, (p, c) => p + c) * 100).toStringAsFixed(1)}%',
            radius: radius,
            titleStyle:
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: textColor),
          );
        case 1:
          return PieChartSectionData(
            color: abortedColor,
            value: values[1],
            title: '${(values[1] / values.fold(0, (p, c) => p + c) * 100).toStringAsFixed(1)}%',
            radius: radius,
            titleStyle:
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: textColor),
          );
        case 2:
          return PieChartSectionData(
            color: abandonedColor,
            value: values[2],
            title: '${(values[2] / values.fold(0, (p, c) => p + c) * 100).toStringAsFixed(1)}%',
            radius: radius,
            titleStyle:
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: textColor),
          );
        default:
          throw Error();
      }
    });
  }

  Future<dynamic> refreshState() async {
    if (!mounted) return;
    _refreshValues();
    setState(() {});
    await Future<dynamic>.delayed(Duration(milliseconds: 3000));
    await refreshState();
  }
}
