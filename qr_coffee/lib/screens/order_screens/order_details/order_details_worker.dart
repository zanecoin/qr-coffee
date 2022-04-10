import 'package:provider/provider.dart';
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
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

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
    if (staticOrder.status != OrderStatus.waiting &&
        staticOrder.status != OrderStatus.ready &&
        staticOrder.status != OrderStatus.withdraw) {
      _static = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return StreamBuilder4<UserData, List<Order>, List<Order>, dynamic>(
      streams: Tuple4(
        UserDatabase(userID: staticOrder.userID).userData,
        CompanyOrderDatabase(companyID: staticOrder.companyID).activeOrderList,
        CompanyOrderDatabase(companyID: staticOrder.companyID).passiveTodayOrderList,
        Stream.periodic(const Duration(milliseconds: 1000)),
      ),
      builder: (context, snapshots) {
        if (snapshots.item2.hasData && snapshots.item3.hasData) {
          UserData? userData = snapshots.item1.data;
          List<Order> allOrders = snapshots.item2.data! + snapshots.item3.data!;

          Order? order = _static ? staticOrder : getUpdatedOrder(allOrders, staticOrder);

          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
          String remainingTime = '';
          Color textColor = themeProvider.themeAdditionalData().textColor!;

          if (order == null) {
            return Scaffold(
              backgroundColor: themeProvider.themeData().backgroundColor,
              appBar: customAppBar(context, title: Text('')),
              body: Center(
                child: Text(
                  AppStringValues.orderNotFound,
                  style: TextStyle(
                    color: themeProvider.themeAdditionalData().textColor,
                  ),
                ),
              ),
            );
          } else {
            // Header format chooser.
            if (order.status == OrderStatus.waiting ||
                order.status == OrderStatus.ready ||
                order.status == OrderStatus.withdraw) {
              List returnArray = time == ''
                  ? ['?', textColor]
                  : getRemainingTime(order, time, themeProvider, false);
              remainingTime = returnArray[0];
              textColor = returnArray[1];
            } else {
              remainingTime = '${timeFormatter(order.pickUpTime)}';
            }

            return Scaffold(
              backgroundColor: themeProvider.themeData().backgroundColor,
              appBar: customAppBar(
                context,
                title: Text(
                  remainingTime,
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
              ),
              body: userData == null && order.status != OrderStatus.generated
                  ? Center(child: Text(AppStringValues.userNotFound))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // ORDER RESULT INFO WINDOW -------------------------
                          SizedBox(height: 10),
                          ResultWindowChooser(
                            order: order,
                            mode: mode,
                            role: UserRole.worker,
                          ),

                          // QR CODE OR FANCY INFO CARD -----------------------
                          FancyInfoCard(order: order),

                          // ORDER HEADER INFO --------------------------------
                          _header(order),
                          SizedBox(height: 10),

                          // ACTION BUTTONS -----------------------------------
                          if (userData != null) _resultButtons(order, themeProvider),
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

  Widget _header(Order order) {
    return Column(
      children: [
        CustomDividerWithText(text: AppStringValues.items),
        SizedBox(
          width: Responsive.isLargeDevice(context) ? Responsive.width(60.0, context) : null,
          child: ListView.builder(
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
              child: CustomTextBanner(title: order.items.values.toList()[index], showIcon: false),
            ),
            itemCount: order.items.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
        if (order.status == OrderStatus.waiting || order.status == OrderStatus.ready)
          CustomDividerWithText(text: AppStringValues.actions),
      ],
    );
  }

  Widget _resultButtons(Order order, ThemeProvider themeProvider) {
    return Column(
      children: [
        if (order.status == OrderStatus.waiting && mode == 'normal')
          ResultButton(
            text: AppStringValues.ready,
            icon: Icons.done,
            color: Colors.green,
            order: order,
            status: OrderStatus.ready,
            previousContext: context,
          ),
        if (order.status == OrderStatus.ready && mode == 'normal' && _showButtons)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ResultButton(
                    text: AppStringValues.abandoned,
                    icon: Icons.clear,
                    color: Colors.red,
                    order: order,
                    status: OrderStatus.abandoned,
                    previousContext: context,
                  ),
                  ResultButton(
                    text: AppStringValues.collected,
                    icon: Icons.done,
                    color: Colors.green,
                    order: order,
                    status: OrderStatus.completed,
                    previousContext: context,
                  ),
                ],
              ),
            ],
          ),
        if (order.status == OrderStatus.ready && mode == 'normal' && !_showButtons)
          Column(
            children: [
              TextButton(
                onPressed: () {
                  setState(() => _showButtons = true);
                },
                child: Text(AppStringValues.manualAnswer),
                style: TextButton.styleFrom(
                  backgroundColor: themeProvider.themeAdditionalData().blendedColor,
                  primary: themeProvider.themeAdditionalData().blendedInvertColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ],
          ),
        if (order.status == OrderStatus.withdraw)
          ResultButton(
            text: AppStringValues.collected,
            icon: Icons.done,
            color: Colors.green,
            order: order,
            status: OrderStatus.completed,
            previousContext: context,
          ),
      ],
    );
  }
}
