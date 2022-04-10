import 'dart:async';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_company/common/company_products.dart';
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
    final company = Provider.of<Company>(context);
    return StreamBuilder4<List<Order>, List<Order>, List<Order>, dynamic>(
      streams: Tuple4(
        CompanyOrderDatabase(companyID: shop.companyID).passiveTodayOrderList,
        CompanyOrderDatabase(companyID: shop.companyID).passiveAllOrderList,
        CompanyOrderDatabase(companyID: shop.companyID).activeOrderList,
        Stream.periodic(const Duration(seconds: 1)),
      ),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData && snapshots.item2.hasData && snapshots.item3.hasData) {
          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

          List<Order> passiveOrderList = snapshots.item1.data!;
          passiveOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));
          passiveOrderList = passiveOrderList.reversed.toList();

          List<Order> passiveAllOrderList = snapshots.item3.data!;

          List<Order> activeOrderList = _filterOutPending(snapshots.item3.data!);
          activeOrderList.sort((a, b) => a.pickUpTime.compareTo(b.pickUpTime));

          List<Order> orderList = activeOrderList + passiveOrderList;
          orderList = _getOrderByPlace(orderList, shop.shopID);
          orderList = _getOrderByType(orderList);

          return Scaffold(
            backgroundColor: themeProvider.themeData().backgroundColor,
            appBar: customAppBar(context,
                title: Text(shop.address,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: themeProvider.themeAdditionalData().textColor,
                    )),
                type: 1,
                actions: [_add(themeProvider), _products(themeProvider, company)]),
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _filterDropDown(themeProvider),
                    if (orderList.isNotEmpty) _orderList(orderList, time),
                    if (orderList.isEmpty)
                      Center(
                          child: Text(
                        AppStringValues.noOrders,
                        style: TextStyle(
                          color: themeProvider.themeAdditionalData().textColor,
                        ),
                      )),
                    const SizedBox(height: 20.0),
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

  Widget _products(ThemeProvider themeProvider, Company company) {
    return IconButton(
      onPressed: () => Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => StreamProvider(
            create: (context) => CompanyDatabase(companyID: company.companyID).company,
            initialData: Company.initialData(),
            catchError: (_, __) => Company.initialData(),
            child: CompanyProducts(),
          ),
        ),
      ),
      icon: Icon(Icons.no_food, color: themeProvider.themeAdditionalData().textColor),
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
                order.status == OrderStatus.abandoned ||
                order.status == OrderStatus.generated)) {
          result.add(order);
        }
        if (_currentFilter == AppStringValues.active &&
            (order.status == OrderStatus.waiting ||
                order.status == OrderStatus.ready ||
                order.status == OrderStatus.withdraw)) {
          result.add(order);
        }
        if (_currentFilter == AppStringValues.picked &&
            (order.status == OrderStatus.completed || order.status == OrderStatus.generated)) {
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
        itemBuilder: (context, index) =>
            OrderTile(order: orderList[index], time: time, role: UserRole.worker),
        itemCount: orderList.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget _filterDropDown(ThemeProvider themeProvider) {
    List types = [
      [AppStringValues.all, allIcon(size: 25.0, themeProvider: themeProvider)],
      [AppStringValues.completed, thumbIcon(size: 25.0, themeProvider: themeProvider)],
      [AppStringValues.active, waitingIcon(size: 25.0)],
      [AppStringValues.picked, checkIcon(size: 25.0, color: Colors.green.shade400)],
      [AppStringValues.unpicked, questionIcon(size: 25.0)],
      [AppStringValues.aborted, errorIcon(size: 25.0)],
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(18.0)),
        boxShadow: themeProvider.themeAdditionalData().shadow,
        color: themeProvider.themeAdditionalData().containerColor,
      ),
      child: Column(
        children: [
          if (Responsive.isSmallDevice(context))
            Text(
              AppStringValues.filter,
              style: TextStyle(
                color: themeProvider.themeAdditionalData().textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          Row(
            children: [
              if (!Responsive.isSmallDevice(context))
                Text(
                  AppStringValues.filter,
                  style: TextStyle(
                    color: themeProvider.themeAdditionalData().textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              const SizedBox(width: 15.0),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                  width: Responsive.isLargeDevice(context) ? 400 : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: themeProvider.themeAdditionalData().containerColor,
                        border: Border.all(
                            width: 1, color: themeProvider.themeAdditionalData().unselectedColor!),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField(
                            dropdownColor: themeProvider.themeAdditionalData().buttonColor,
                            style: TextStyle(color: themeProvider.themeAdditionalData().textColor),
                            value: _currentFilter,
                            items: types.map((type) {
                              return DropdownMenuItem(
                                child: Row(
                                  children: [
                                    type[1],
                                    Text(
                                      ' ${type[0]}',
                                      style: TextStyle(
                                          color: themeProvider.themeAdditionalData().textColor),
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
