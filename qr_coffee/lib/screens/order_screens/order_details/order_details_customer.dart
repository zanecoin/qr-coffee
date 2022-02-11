import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_details/functions.dart';
import 'package:qr_coffee/screens/order_screens/order_details/result_button.dart';
import 'package:qr_coffee/screens/order_screens/order_details/widgets.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:intl/intl.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

// SCREEN WITH ORDER SUMMARY -------------------------------------------------------------------------------------------
class OrderDetailsCustomer extends StatefulWidget {
  OrderDetailsCustomer({Key? key, required this.order, required this.mode}) : super(key: key);

  final Order order;
  final String mode;

  @override
  _OrderDetailsCustomerState createState() =>
      _OrderDetailsCustomerState(staticOrder: order, mode: mode);
}

class _OrderDetailsCustomerState extends State<OrderDetailsCustomer> {
  _OrderDetailsCustomerState({required this.staticOrder, required this.mode});

  final Order staticOrder;
  final String mode;

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
        UserDatabase(uid: staticOrder.userId).userData,
        UserOrderDatabase(uid: staticOrder.userId).activeOrderList,
        UserOrderDatabase(uid: staticOrder.userId).passiveOrderList,
        Stream.periodic(const Duration(milliseconds: 1000)),
      ),
      builder: (context, snapshots) {
        if (snapshots.item2.hasData && snapshots.item3.hasData) {
          UserData? userData = snapshots.item1.data;
          List<Order> allOrders = snapshots.item2.data! + snapshots.item3.data!;

          Order? order = _static ? staticOrder : getUpdatedOrder(allOrders, staticOrder);

          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
          String remainingTime = '';
          Color color = Colors.black;
          final double deviceWidth = Responsive.deviceWidth(context);

          if (order == null) {
            return Scaffold(
              appBar: customAppBar(context, title: Text('')),
              body: Center(
                child: Text(CzechStrings.orderNotFound),
              ),
            );
          } else {
            // Show alert if user tries to claim order which is not ready.
            if (order.triggerNum == 1) {
              _showAlert = true;
            }

            // Header format chooser.
            if (order.status == 'ACTIVE' || order.status == 'READY') {
              List returnArray = time == '' ? ['?', Colors.black] : getRemainingTime(order, time);
              remainingTime = returnArray[0];
              color = returnArray[1];
            } else {
              remainingTime = '${timeFormatter(order.pickUpTime)}';
              color = Colors.black;
            }

            return Scaffold(
              appBar:
                  customAppBar(context, title: Text(remainingTime, style: TextStyle(color: color))),
              body: userData == null && order.userId != 'generated-order^^'
                  ? Center(child: Text(CzechStrings.userNotFound))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // ORDER RESULT INFO WINDOW -------------------------
                          SizedBox(height: 10),
                          ResultWindowChooser(
                            order: order,
                            mode: mode,
                            role: userData!.role,
                          ),

                          // QR CODE OR FANCY INFO CARD -----------------------
                          QrCard(order: order),

                          // ORDER HEADER INFO --------------------------------
                          _header(order, deviceWidth),
                          SizedBox(height: 10),

                          // ACTION BUTTONS -----------------------------------
                          _resultButtons(order, userData),
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

  Widget _header(Order order, double deviceWidth) {
    return Column(
      children: [
        if (order.status != 'ABORTED')
          Text(
            '${order.price.toString()} ${CzechStrings.currency}',
            style: TextStyle(
              fontSize: 30,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (order.status == 'ABORTED')
          Column(
            children: [
              Text(
                '${CzechStrings.returned} ${order.price.toString()} ${CzechStrings.currency} ${CzechStrings.inTokens}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        Text(
          order.shop,
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        CustomDivider(
          indent: deviceWidth < kDeviceUpperWidthTreshold ? 40 : Responsive.width(30, context),
        ),
        SizedBox(
          child: ListView.builder(
            itemBuilder: (context, index) =>
                Center(child: Text(order.items[index], style: TextStyle(fontSize: 20))),
            itemCount: order.items.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
      ],
    );
  }

  Widget _resultButtons(Order order, UserData userData) {
    return Column(
      children: [
        if ((order.status == 'ACTIVE' || order.status == 'READY') && mode == 'normal')
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ResultButton(
                    userData: userData,
                    text: CzechStrings.cancelOrder,
                    icon: Icons.clear,
                    color: Colors.red,
                    order: order,
                    status: 'ABORTED',
                    previousContext: context,
                    role: userData.role,
                  ),
                ],
              ),
            ],
          ),

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
