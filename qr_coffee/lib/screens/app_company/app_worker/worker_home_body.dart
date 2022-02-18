import 'dart:async';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/create_order/create_order_screen.dart';
import 'package:qr_coffee/screens/order_screens/order_tile.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class WorkerHomeBody extends StatefulWidget {
  WorkerHomeBody({required this.shop, required this.databaseImages});
  final Shop shop;
  final List<Map<String, dynamic>> databaseImages;

  @override
  _WorkerHomeBodyState createState() =>
      _WorkerHomeBodyState(shop: shop, databaseImages: databaseImages);
}

class _WorkerHomeBodyState extends State<WorkerHomeBody> {
  _WorkerHomeBodyState({required this.shop, required this.databaseImages});
  final Shop shop;
  final List<Map<String, dynamic>> databaseImages;

  dynamic _currentFilter = AppStringValues.active;

  @override
  Widget build(BuildContext context) {
    // GET CURRENTLY LOGGED USER AND DATA STREAMS
    final user = Provider.of<User?>(context);
    return StreamBuilder4<List<Order>, List<Order>, UserData, dynamic>(
      streams: Tuple4(
          CompanyOrderDatabase().passiveOrderList,
          CompanyOrderDatabase().activeOrderList,
          UserDatabase(uid: user!.uid).userData,
          Stream.periodic(const Duration(seconds: 1))),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData && snapshots.item2.hasData && snapshots.item3.hasData) {
          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
          UserData userData = snapshots.item3.data!;

          List<Order> passiveOrderList = snapshots.item1.data!;
          passiveOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));
          passiveOrderList = passiveOrderList.reversed.toList();

          List<Order> activeOrderList = _filterOutPending(snapshots.item2.data!, userData);
          activeOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));

          List<Order> orderList = activeOrderList + passiveOrderList;
          orderList = _getOrderByPlace(orderList, shop.uid);
          orderList = _getOrderByType(orderList);

          return Scaffold(
            appBar: customAppBar(context,
                title: Text(shop.address, style: TextStyle(fontSize: 14)),
                type: 1,
                actions: [_add(databaseImages)]),
            body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _filterDropDown(),
                    CustomDivider(),
                    if (orderList.isNotEmpty) _orderList(orderList, time),
                    if (orderList.isEmpty) Center(child: Text(AppStringValues.noOrders)),
                    SizedBox(height: 20),
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

  Widget _add(List<Map<String, dynamic>> databaseImages) {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => CreateOrderScreen(shop: shop, databaseImages: databaseImages)),
      ),
      icon: Icon(Icons.add_box_outlined),
    );
  }

  List<Order> _filterOutPending(List<Order> orders, UserData userData) {
    List<Order> result = [];
    for (var item in orders) {
      if (item.status != 'PENDING') {
        result.add(item);
      }
    }
    return result;
  }

  List<Order> _getOrderByPlace(List<Order> orders, String shopId) {
    List<Order> result = [];
    for (var item in orders) {
      if (item.shopId == shopId) {
        result.add(item);
      }
    }
    return result;
  }

  List<Order> _getOrderByType(List<Order> orders) {
    List<Order> result = [];
    if (_currentFilter == AppStringValues.all) {
      return orders;
    } else {
      for (var order in orders) {
        if (_currentFilter == AppStringValues.completed &&
            (order.status == 'COMPLETED' ||
                order.status == 'ABORTED' ||
                order.status == 'ABANDONED')) {
          result.add(order);
        }
        if (_currentFilter == AppStringValues.active &&
            (order.status == 'ACTIVE' || order.status == 'READY')) {
          result.add(order);
        }
        if (_currentFilter == AppStringValues.picked && order.status == 'COMPLETED') {
          result.add(order);
        }
        if (_currentFilter == AppStringValues.unpicked && order.status == 'ABANDONED') {
          result.add(order);
        }
        if (_currentFilter == AppStringValues.aborted && order.status == 'ABORTED') {
          result.add(order);
        }
      }
    }
    ;
    return result;
  }

  Widget _orderList(List<Order> orderList, String time) {
    return SizedBox(
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
    );
  }

  Widget _filterDropDown() {
    List types = [
      [AppStringValues.all, allIcon(size: 25)],
      [AppStringValues.completed, thumbIcon(size: 25)],
      [AppStringValues.active, waitingIcon(size: 25)],
      [AppStringValues.picked, checkIcon(size: 25, color: Colors.green.shade400)],
      [AppStringValues.unpicked, questionIcon(size: 25)],
      [AppStringValues.aborted, errorIcon(size: 25)],
    ];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: Responsive.deviceWidth(context) > kDeviceUpperWidthTreshold ? 400 : null,
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
                      children: [type[1], Text(' ${type[0]}')],
                    ),
                    value: type[0],
                  );
                }).toList(),
                onChanged: (val) => setState(() => _currentFilter = val),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
