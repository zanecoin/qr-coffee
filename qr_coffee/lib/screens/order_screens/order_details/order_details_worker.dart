import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/order_details/fancy_info_card.dart';
import 'package:qr_coffee/screens/order_screens/order_details/functions.dart';
import 'package:qr_coffee/screens/order_screens/order_details/result_button.dart';
import 'package:qr_coffee/screens/order_screens/order_details/result_window_qr.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:intl/intl.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

// SCREEN WITH ORDER SUMMARY -------------------------------------------------------------------------------------------
class OrderDetailsWorker extends StatefulWidget {
  OrderDetailsWorker({Key? key, required this.order, required this.mode}) : super(key: key);

  final Order order;
  final String mode;

  @override
  _OrderDetailsWorkerState createState() =>
      _OrderDetailsWorkerState(staticOrder: order, mode: mode);
}

class _OrderDetailsWorkerState extends State<OrderDetailsWorker> {
  _OrderDetailsWorkerState({required this.staticOrder, required this.mode});

  final Order staticOrder;
  final String mode;

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
        UserDatabase(uid: staticOrder.userId).userData,
        CompanyOrderDatabase().activeOrderList,
        CompanyOrderDatabase().passiveOrderList,
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
                child: Text(AppStringValues.orderNotFound),
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
              appBar: customAppBar(
                context,
                title: Text(
                  remainingTime,
                  style: TextStyle(color: color, fontSize: 18),
                ),
              ),
              body: userData == null && order.userId != 'generated-order^^'
                  ? Center(child: Text(AppStringValues.userNotFound))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // ORDER RESULT INFO WINDOW -------------------------
                          SizedBox(height: 10),
                          ResultWindowChooser(
                            order: order,
                            mode: mode,
                            role: 'worker',
                          ),

                          // QR CODE OR FANCY INFO CARD -----------------------
                          FancyInfoCard(order: order),

                          // ORDER HEADER INFO --------------------------------
                          _header(order, deviceWidth),
                          SizedBox(height: 10),

                          // ACTION BUTTONS -----------------------------------
                          if (userData != null) _resultButtons(order, userData),
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
        CustomDividerWithText(text: AppStringValues.items),
        SizedBox(
          child: ListView.builder(
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
              child: CustomTextBanner(title: order.items[index], showIcon: false),
            ),
            itemCount: order.items.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
        if (order.status == 'ACTIVE' || order.status == 'READY')
          CustomDividerWithText(text: AppStringValues.actions),
      ],
    );
  }

  Widget _resultButtons(Order order, UserData userData) {
    return Column(
      children: [
        if (order.status == 'ACTIVE' && mode == 'normal')
          ResultButton(
            userData: userData,
            text: AppStringValues.ready,
            icon: Icons.done,
            color: Colors.green,
            order: order,
            status: 'READY',
            previousContext: context,
          ),
        if (order.status == 'READY' && mode == 'normal' && _showButtons)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ResultButton(
                    userData: userData,
                    text: AppStringValues.abandoned,
                    icon: Icons.clear,
                    color: Colors.red,
                    order: order,
                    status: 'ABANDONED',
                    previousContext: context,
                  ),
                  ResultButton(
                    userData: userData,
                    text: AppStringValues.collected,
                    icon: Icons.done,
                    color: Colors.green,
                    order: order,
                    status: 'COMPLETED',
                    previousContext: context,
                  ),
                ],
              ),
            ],
          ),
        if (order.status == 'READY' && mode == 'normal' && !_showButtons)
          Column(
            children: [
              TextButton(
                onPressed: () {
                  setState(() => _showButtons = true);
                },
                child: Text(AppStringValues.manualAnswer),
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
      ],
    );
  }
}
