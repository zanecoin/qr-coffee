import 'package:community_material_icon/community_material_icon.dart';
import 'package:qr_coffee/models/customer.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/screens/order_screens/order_details/fancy_info_card.dart';
import 'package:qr_coffee/screens/order_screens/order_details/functions.dart';
import 'package:qr_coffee/screens/order_screens/order_details/qr_scan_screen.dart';
import 'package:qr_coffee/screens/order_screens/order_details/result_function.dart';
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
  bool _static = false;

  @override
  void initState() {
    super.initState();
    if (staticOrder.status != 'ACTIVE' &&
        staticOrder.status != 'READY' &&
        staticOrder.status != 'PENDING') {
      _static = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder4<Customer, List<Order>, List<Order>, dynamic>(
      streams: Tuple4(
        CustomerDatabase(userID: staticOrder.userID).customer,
        CustomerOrderDatabase(userID: staticOrder.userID).activeOrderList,
        CustomerOrderDatabase(userID: staticOrder.userID).passiveOrderList,
        Stream.periodic(const Duration(milliseconds: 1000)),
      ),
      builder: (context, snapshots) {
        if (snapshots.item2.hasData && snapshots.item3.hasData) {
          Customer? customer = snapshots.item1.data;
          List<Order> allOrders = snapshots.item2.data! + snapshots.item3.data!;

          Order? order = _static ? staticOrder : getUpdatedOrder(allOrders, staticOrder);

          String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
          String remainingTime = '';
          Color color = Colors.black;
          final double deviceWidth = Responsive.deviceWidth(context);

          // If Mode 'qr' is here, back arrow needs to do double pop(context).
          _doublePop() {
            Navigator.pop(context);
            Navigator.pop(context);
          }

          if (order == null) {
            return Scaffold(
              appBar: customAppBar(context, title: Text('')),
              body: Center(
                child: Text(AppStringValues.orderNotFound),
              ),
            );
          } else {
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
                title: Text(remainingTime, style: TextStyle(color: color, fontSize: 18)),
                type: 1,
                function: mode == 'qr' ? _doublePop : null,
              ),
              body: customer == null && order.userID != 'generated-order^^'
                  ? Center(child: Text(AppStringValues.userNotFound))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // ORDER RESULT INFO WINDOW -------------------------
                          SizedBox(height: 10),
                          ResultWindowChooser(
                            order: order,
                            mode: mode,
                            role: customer!.role,
                          ),
                          if (order.status == 'ABORTED') _returnInfo(order),

                          // QR CODE OR FANCY INFO CARD -----------------------
                          FancyInfoCard(order: order),

                          // ORDER HEADER INFO --------------------------------
                          _header(order, deviceWidth),

                          // ACTION BUTTONS -----------------------------------
                          _resultButtons(order, customer),
                          SizedBox(height: 30),
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

  Widget _returnInfo(Order order) {
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 5),
            Text(
              '${AppStringValues.returned} ${order.price.toString()} ${AppStringValues.currency} ${AppStringValues.inTokens}',
              style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _header(Order order, double deviceWidth) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.place),
            Text(
              order.shop.length < Responsive.textTreshold(context)
                  ? '${order.shop}'
                  : '${order.shop.substring(0, Responsive.textTreshold(context))}...',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ],
        ),
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

  Widget _resultButtons(Order order, Customer customer) {
    _abortOrder() {
      moveOrderToPassive(order, 'ABORTED', customer);
    }

    _triggerAlert() {
      customAlertDialog(context, _abortOrder);
    }

    _triggerQrScan() {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => QRScanScreen(order: order)));
    }

    _triggerInfoSnackBar() {
      customSnackbar(context: context, text: AppStringValues.waitForReady);
    }

    return Column(
      children: [
        if ((order.status == 'ACTIVE' || order.status == 'READY'))
          Column(
            children: [
              if (order.status == 'READY')
                CustomOutlinedIconButton(
                  function: _triggerQrScan,
                  icon: Icons.qr_code_2_outlined,
                  label: AppStringValues.pickUpOrder,
                  iconColor: Colors.green,
                ),
              if (order.status == 'ACTIVE')
                CustomOutlinedIconButton(
                  function: _triggerInfoSnackBar,
                  icon: Icons.qr_code_2_outlined,
                  label: AppStringValues.pickUpOrder,
                  iconColor: Colors.grey,
                  outlineColor: Colors.grey,
                ),
              SizedBox(height: 5.0),
              CustomOutlinedIconButton(
                function: _triggerAlert,
                icon: CommunityMaterialIcons.skull_crossbones,
                label: AppStringValues.cancelOrder,
                iconColor: Colors.red,
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
