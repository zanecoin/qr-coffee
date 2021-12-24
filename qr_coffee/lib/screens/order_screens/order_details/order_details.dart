import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_details/fancy_info_card.dart';
import 'package:qr_coffee/screens/order_screens/order_details/result_button.dart';
import 'package:qr_coffee/screens/order_screens/order_details/widgets.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:qr_coffee/shared/widgets/custom_divider.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:intl/intl.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_flutter/qr_flutter.dart';

// SCREEN WITH ORDER SUMMARY -------------------------------------------------------------------------------------------
class OrderDetails extends StatefulWidget {
  final Order order;
  final String role;
  final String mode;
  OrderDetails({
    Key? key,
    required this.order,
    required this.role,
    required this.mode,
  }) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState(
        staticOrder: order,
        role: role,
        mode: mode,
      );
}

class _OrderDetailsState extends State<OrderDetails> {
  final Order staticOrder;
  final String role;
  final String mode;
  _OrderDetailsState({
    required this.staticOrder,
    required this.role,
    required this.mode,
  });

  bool _showButtons = false;
  bool _showAlert = false;
  bool _static = false;

  @override
  void initState() {
    super.initState();
    if (staticOrder.status != 'ACTIVE' && staticOrder.status != 'READY') {
      _static = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder4<UserData, List<Order>, List<Order>, dynamic>(
      streams: Tuple4(
        DatabaseService(uid: staticOrder.userId).userData,
        DatabaseService().activeOrderList,
        DatabaseService().passiveOrderList,
        Stream.periodic(const Duration(milliseconds: 100)),
      ),
      builder: (context, snapshots) {
        if (snapshots.item2.hasData && snapshots.item3.hasData) {
          UserData? userData = snapshots.item1.data;
          List<Order> orders = snapshots.item2.data! + snapshots.item3.data!;
          Order? order =
              _static ? staticOrder : _getUpdatedOrder(orders, staticOrder);
          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
          String remainingTime = '';
          Color color = Colors.black;
          final double deviceWidth = Responsive.deviceWidth(context);

          if (order == null) {
            return Scaffold(
              appBar: customAppBar(context, title: Text('')),
              body: Center(
                child: Text(
                  CzechStrings.orderNotFound,
                ),
              ),
            );
          } else {
            // SHOW ALERT IF USER TRIES TO REDEEM ORDER WHICH IS NOT READY
            if (order.triggerNum == 1) {
              _showAlert = true;
            }

            // INFORMATION HEADER FORMAT CHOOSER
            if (order.status == 'ACTIVE' || order.status == 'READY') {
              List returnArray = time == ''
                  ? ['?', Colors.black]
                  : getRemainingTime(order, time);
              remainingTime = returnArray[0];
              color = returnArray[1];
            } else {
              remainingTime = '${timeFormatter(order.pickUpTime)}';
              color = Colors.black;
            }

            return Scaffold(
              appBar: customAppBar(context,
                  title: Text(remainingTime, style: TextStyle(color: color))),
              body: userData == null
                  ? Center(child: Text(CzechStrings.userNotFound))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // ORDER RESULT INFO WINDOW -------------------------
                          SizedBox(height: 10),
                          _resultInfo(order),

                          // QR CODE OR FANCY INFO CARD -----------------------
                          if (role == 'customer' || role == 'worker-off')
                            QrCard(order: order),
                          if (role == 'worker-on')
                            FancyInfoCard(order: order, userData: userData),

                          // ORDER HEADER INFO --------------------------------
                          _header(order, deviceWidth),
                          SizedBox(height: 10),

                          // ACTION BUTTONS -----------------------------------
                          _resultButtons(order),
                          SizedBox(height: 30),
                          if (_showAlert) Text('not ready'),
                        ],
                      ),
                    ),
            );
          }
        } else {
          return Loading();
        }
      },
    );
  }

  Order? _getUpdatedOrder(List<Order> orderList, Order order) {
    Order? result;
    for (var item in orderList) {
      if (item.orderId == order.orderId) {
        result = item;
      }
    }
    return result;
  }

  Widget _resultInfo(Order order) {
    return Column(
      children: [
        if (order.status == 'COMPLETED')
          ResultWindow(
            text: CzechStrings.orderCollected,
            color: Colors.green.shade100,
            icon: checkIcon(color: Colors.green.shade400),
          ),
        if (order.status == 'ABANDONED')
          ResultWindow(
            text: CzechStrings.orderAbandoned,
            color: Colors.orange.shade100,
            icon: questionIcon(),
          ),
        if (order.status == 'ABORTED')
          ResultWindow(
            text: CzechStrings.orderCancelled,
            color: Colors.red.shade100,
            icon: errorIcon(),
          ),
        if (order.status == 'PENDING')
          ResultWindow(
            text: CzechStrings.orderPending,
            color: Colors.blue.shade100,
            icon: waitingIcon(),
          ),
        if (order.status == 'READY')
          ResultWindow(
            text: CzechStrings.orderReady,
            color: role == 'customer'
                ? Colors.green.shade100
                : Colors.blue.shade100,
            icon: checkIcon(
              color: role == 'customer'
                  ? Colors.green.shade400
                  : Colors.blue.shade400,
            ),
          ),
        if (mode == 'after-creation')
          if (order.status == 'ACTIVE')
            ResultWindow(
              text: CzechStrings.orderRecieved,
              color: Colors.blue.shade100,
              icon: checkIcon(color: Colors.blue.shade400),
            ),
      ],
    );
  }

  Widget _header(Order order, double deviceWidth) {
    return Column(
      children: [
        if (role == 'customer')
          Text(
            '${order.price.toString()} Kč',
            style: TextStyle(
                fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        if (role == 'customer')
          Text(
            order.place,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        if (role == 'customer' || role == 'worker-off')
          CustomDivider(
            indent: deviceWidth < kDeviceUpperWidthTreshold
                ? 40
                : Responsive.width(30, context),
          ),
        SizedBox(
          child: ListView.builder(
            itemBuilder: (context, index) => Center(
                child: Text(
              order.items[index],
              style: TextStyle(fontSize: 20),
            )),
            itemCount: order.items.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
      ],
    );
  }

  Widget _resultButtons(Order order) {
    return Column(
      children: [
        if (order.status == 'ACTIVE' && role == 'worker-on' && mode == 'normal')
          ResultButton(
            text: CzechStrings.ready,
            icon: Icons.done,
            color: Colors.green,
            order: order,
            status: 'READY',
            previousContext: context,
            role: role,
          ),
        if (order.status == 'READY' &&
            role == 'worker-on' &&
            mode == 'normal' &&
            _showButtons)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ResultButton(
                    text: CzechStrings.abandoned,
                    icon: Icons.clear,
                    color: Colors.red,
                    order: order,
                    status: 'ABANDONED',
                    previousContext: context,
                    role: role,
                  ),
                  ResultButton(
                    text: CzechStrings.collected,
                    icon: Icons.done,
                    color: Colors.green,
                    order: order,
                    status: 'COMPLETED',
                    previousContext: context,
                    role: role,
                  ),
                ],
              ),
            ],
          ),
        if (order.status == 'READY' &&
            role == 'worker-on' &&
            mode == 'normal' &&
            !_showButtons)
          Column(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showButtons = true;
                  });
                },
                child: Text(CzechStrings.manualAnswer),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  primary: Colors.grey.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ],
          ),
        if ((order.status == 'ACTIVE' || order.status == 'READY') &&
            role == 'customer' &&
            mode == 'normal')
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ResultButton(
                    text: CzechStrings.cancelOrder,
                    icon: Icons.clear,
                    color: Colors.red,
                    order: order,
                    status: 'ABORTED',
                    previousContext: context,
                    role: role,
                  ),
                ],
              ),
            ],
          ),

        // if (order.status != 'ACTIVE' && role == 'customer')
        //   Column(
        //     children: [
        //       SizedBox(height: 20),
        //       Row(
        //         mainAxisAlignment:
        //             MainAxisAlignment.spaceEvenly,
        //         children: [
        //           _resultBtn('ACTIVE', 'Objednat znovu',
        //               Icons.refresh, Colors.green, order),
        //         ],
        //       ),
        //       Text(
        //         'Na ${timeFormatter(order.pickUpTime).substring(0, 5)}',
        //         style: TextStyle(fontSize: 18),
        //       ),
        //       Text(
        //         '(Platba uloženou kartou)',
        //         style: TextStyle(fontSize: 18),
        //       )
        //     ],
        //   ),
      ],
    );
  }
}