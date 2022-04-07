import 'dart:async';
import 'package:provider/provider.dart';
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
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class WorkerHomeBody extends StatefulWidget {
  WorkerHomeBody({required this.shop});
  final Shop shop;

  @override
  _WorkerHomeBodyState createState() => _WorkerHomeBodyState(shop: shop);
}

class _WorkerHomeBodyState extends State<WorkerHomeBody> {
  _WorkerHomeBodyState({required this.shop});
  final Shop shop;

  dynamic _currentFilter = AppStringValues.active;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return StreamBuilder3<List<Order>, List<Order>, dynamic>(
      streams: Tuple3(
        CompanyOrderDatabase(companyID: shop.companyID).passiveOrderList,
        CompanyOrderDatabase(companyID: shop.companyID).activeOrderList,
        Stream.periodic(const Duration(seconds: 1)),
      ),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData && snapshots.item2.hasData) {
          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

          List<Order> passiveOrderList = snapshots.item1.data!;
          passiveOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));
          passiveOrderList = passiveOrderList.reversed.toList();

          List<Order> activeOrderList = _filterOutPending(snapshots.item2.data!);
          activeOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));

          List<Order> orderList = activeOrderList + passiveOrderList;
          orderList = _getOrderByPlace(orderList, shop.shopID);
          orderList = _getOrderByType(orderList);

          return Scaffold(
            backgroundColor: themeProvider.themeData().backgroundColor,
            appBar: customAppBar(context,
                title: Text(shop.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.themeAdditionalData().textColor,
                    )),
                type: 1,
                actions: [_add(themeProvider)]),
            body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _filterDropDown(themeProvider),
                    CustomDivider(),
                    if (orderList.isNotEmpty) _orderList(orderList, time),
                    if (orderList.isEmpty)
                      Center(
                          child: Text(
                        AppStringValues.noOrders,
                        style: TextStyle(
                          color: themeProvider.themeAdditionalData().textColor,
                        ),
                      )),
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

  Widget _add(ThemeProvider themeProvider) {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => CreateOrderScreen(shop: shop)),
      ),
      icon: Icon(Icons.add_box_outlined, color: themeProvider.themeAdditionalData().textColor),
    );
  }

  List<Order> _filterOutPending(List<Order> orders) {
    List<Order> result = [];
    for (var item in orders) {
      if (item.status != OrderStatus.pending) {
        result.add(item);
      }
    }
    return result;
  }

  List<Order> _getOrderByPlace(List<Order> orders, String shopID) {
    List<Order> result = [];
    for (var item in orders) {
      if (item.shopID == shopID) {
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
            (order.status == OrderStatus.completed ||
                order.status == OrderStatus.aborted ||
                order.status == OrderStatus.abandoned)) {
          result.add(order);
        }
        if (_currentFilter == AppStringValues.active &&
            (order.status == OrderStatus.waiting || order.status == OrderStatus.ready)) {
          result.add(order);
        }
        if (_currentFilter == AppStringValues.picked && order.status == OrderStatus.completed) {
          result.add(order);
        }
        if (_currentFilter == AppStringValues.unpicked && order.status == OrderStatus.abandoned) {
          result.add(order);
        }
        if (_currentFilter == AppStringValues.aborted && order.status == OrderStatus.aborted) {
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
          role: UserRole.worker,
        ),
        itemCount: orderList.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget _filterDropDown(ThemeProvider themeProvider) {
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
            border:
                Border.all(width: 1, color: themeProvider.themeAdditionalData().unselectedColor!),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                style: TextStyle(
                  color: themeProvider.themeAdditionalData().textColor,
                ),
                value: _currentFilter,
                items: types.map((type) {
                  return DropdownMenuItem(
                    child: Row(
                      children: [
                        type[1],
                        Text(
                          ' ${type[0]}',
                          style: TextStyle(
                            color: themeProvider.themeAdditionalData().textColor,
                          ),
                        ),
                      ],
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
