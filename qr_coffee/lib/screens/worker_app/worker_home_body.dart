import 'dart:async';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_inventory.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/custom_small_widgets.dart';
import 'package:qr_coffee/shared/loading.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WorkerHomeBody extends StatefulWidget {
  final List<Order> activeOrderList;
  final UserData userData;
  const WorkerHomeBody(
      {Key? key, required this.activeOrderList, required this.userData})
      : super(key: key);

  @override
  _WorkerHomeBodyState createState() => _WorkerHomeBodyState();
}

class _WorkerHomeBodyState extends State<WorkerHomeBody> {
  dynamic _currentFilter = 'Čekající';

  @override
  Widget build(BuildContext context) {
    // GET CURRENTLY LOGGED USER AND DATA STREAMS
    final user = Provider.of<User?>(context);
    return StreamBuilder4<List<Order>, List<Order>, UserData, dynamic>(
      streams: Tuple4(
          DatabaseService().passiveOrderList,
          DatabaseService().activeOrderList,
          DatabaseService(uid: user!.uid).userData,
          Stream.periodic(const Duration(seconds: 1))),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData &&
            snapshots.item2.hasData &&
            snapshots.item3.hasData) {
          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

          UserData userData = snapshots.item3.data!;
          List<Order> passiveOrderList = snapshots.item1.data!;
          List<Order> activeOrderList = snapshots.item2.data!;
          List<Order> orderList = activeOrderList + passiveOrderList;
          orderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));
          orderList = orderList.reversed.toList();
          orderList = _getOrderType(orderList);

          if (userData.stand != '') {
            return SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _orderFilter(),
                    CustomDivider(),
                    if (orderList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: SizedBox(
                          child: ListView.builder(
                            itemBuilder: (context, index) => OrderTile(
                              order: orderList[index],
                              time: time,
                              role: 'worker',
                            ),
                            itemCount: orderList.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                          ),
                        ),
                      ),
                    if (orderList.isEmpty)
                      const Center(child: Text(CzechStrings.noOrders)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.all(45),
              child: Center(
                  child: Text(
                CzechStrings.workerPageInfo,
                textAlign: TextAlign.center,
              )),
            );
          }
        } else {
          return Loading();
        }
      },
    );
  }

  List<Order> _getOrderType(List<Order> orders) {
    List<Order> result = [];
    if (_currentFilter == 'Všechny') {
      return orders;
    } else {
      for (var order in orders) {
        if (_currentFilter == 'Vyřízené' &&
            (order.state == 'complete' ||
                order.state == 'aborted' ||
                order.state == 'abandoned')) {
          result.add(order);
        }
        if (_currentFilter == 'Čekající' && order.state == 'active') {
          result.add(order);
        }
        if (_currentFilter == 'Vyzvednuté' && order.state == 'complete') {
          result.add(order);
        }
        if (_currentFilter == 'Nevyzvednuté' && order.state == 'abandoned') {
          result.add(order);
        }
        if (_currentFilter == 'Zrušené' && order.state == 'aborted') {
          result.add(order);
        }
      }
    }
    ;
    return result;
  }

  Widget _orderFilter() {
    List types = [
      ['Všechny', allIcon(size: 25)],
      ['Vyřízené', thumbIcon(size: 25)],
      ['Čekající', waitingIcon(size: 25)],
      ['Vyzvednuté', checkIcon(size: 25)],
      ['Nevyzvednuté', questionIcon(size: 25)],
      ['Zrušené', errorIcon(size: 25)],
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                value: _currentFilter,
                items: types.map((type) {
                  return DropdownMenuItem(
                    child: Row(
                      children: [
                        type[1],
                        Text(' ${type[0]}'),
                      ],
                    ),
                    value: type[0],
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _currentFilter = val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
