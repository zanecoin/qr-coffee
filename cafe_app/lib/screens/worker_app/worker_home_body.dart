import 'dart:async';
import 'package:cafe_app/models/order.dart';
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/screens/shared_screens/order_inventory.dart';
import 'package:cafe_app/service/database.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:cafe_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:intl/intl.dart';

class WorkerHomeBody extends StatefulWidget {
  const WorkerHomeBody({Key? key}) : super(key: key);

  @override
  _WorkerHomeBodyState createState() => _WorkerHomeBodyState();
}

class _WorkerHomeBodyState extends State<WorkerHomeBody> {
  dynamic _currentFilter = 'Čekající';
  @override
  Widget build(BuildContext context) {
    // get currently logged user and theme provider
    final user = Provider.of<User?>(context);

    // get data streams
    if (user != null) {
      return StreamBuilder3<List<Order>, List<Order>, dynamic>(
        streams: Tuple3(
            DatabaseService(uid: user.uid).activeOrderList,
            DatabaseService(uid: user.uid).passiveOrderList,
            Stream.periodic(const Duration(seconds: 1))),
        builder: (context, snapshots) {
          if (snapshots.item1.hasData && snapshots.item2.hasData) {
            String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
            List<Order> activeOrderList = snapshots.item1.data!;
            List<Order> passiveOrderList = snapshots.item2.data!;
            List<Order> orderList = activeOrderList + passiveOrderList;
            orderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));
            orderList = _getOrderType(orderList);

            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _orderFilter(),
                    CustomDivider(),
                    if (activeOrderList.length > 0)
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
                    if (activeOrderList.length == 0 &&
                        passiveOrderList.length == 0)
                      Text('Žádné objednávky k zobrazení ...'),
                    SizedBox(height: 30),
                  ],
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

  List<Order> _getOrderType(List<Order> orders) {
    List<Order> result = [];
    if (_currentFilter == 'Všechny') {
      return orders;
    } else {
      for (var order in orders) {
        if (_currentFilter == 'Vyřízené') if (order.state == 'active' ||
            order.state == 'aborted' ||
            order.state == 'abandoned' ||
            order.state == 'aborted') {
          result.add(order);
        }
        if (_currentFilter == 'Čekající') if (order.state == 'active') {
          result.add(order);
        }
        if (_currentFilter == 'Vyzvednuté') if (order.state == 'complete') {
          result.add(order);
        }
        if (_currentFilter == 'Nevyzvednuté') if (order.state == 'abandoned') {
          result.add(order);
        }
        if (_currentFilter == 'Zrušené') if (order.state == 'aborted') {
          result.add(order);
        }
      }
    }
    ;
    return result;
  }

  Widget text(String string) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        string,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.left,
      ),
    );
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
                hint: Text('Vyberte odběrové místo'),
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
