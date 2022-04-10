import 'package:community_material_icon/community_material_icon.dart';
import 'package:provider/provider.dart';
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
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

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
    if (staticOrder.status != OrderStatus.waiting &&
        staticOrder.status != OrderStatus.ready &&
        staticOrder.status != OrderStatus.pending) {
      _static = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
          Color textColor = themeProvider.themeAdditionalData().textColor!;

          // If Mode 'qr' is here, back arrow needs to do double pop(context).
          _doublePop() {
            Navigator.pop(context);
            Navigator.pop(context);
          }

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
                title: Text(remainingTime, style: TextStyle(color: textColor, fontSize: 14)),
                type: 1,
                function: mode == 'qr' ? _doublePop : null,
              ),
              body: customer == null && order.status != OrderStatus.generated
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
                          if (order.status == OrderStatus.aborted)
                            _returnInfo(order, themeProvider),

                          // QR CODE OR FANCY INFO CARD -----------------------
                          FancyInfoCard(order: order),

                          // ORDER HEADER INFO --------------------------------
                          _header(order, themeProvider),

                          // ACTION BUTTONS -----------------------------------
                          _resultButtons(order, customer, themeProvider),
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

  Widget _returnInfo(Order order, ThemeProvider themeProvider) {
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 5),
            Text(
              '${AppStringValues.returned} ${order.price.toString()} ${AppStringValues.currency} ${AppStringValues.inCredits}',
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.themeAdditionalData().textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _header(Order order, ThemeProvider themeProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(order.company,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeProvider.themeAdditionalData().textColor,
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.place, color: themeProvider.themeAdditionalData().textColor),
            Text(
              order.shop.length < Responsive.textTreshold(context)
                  ? '${order.shop}'
                  : '${order.shop.substring(0, Responsive.textTreshold(context))}...',
              style: TextStyle(fontSize: 20, color: themeProvider.themeAdditionalData().textColor),
            ),
          ],
        ),
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

  Widget _resultButtons(Order order, Customer customer, ThemeProvider themeProvider) {
    _abortOrder() {
      moveOrderToPassive(order, OrderStatus.aborted, customer);
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
        if ((order.status == OrderStatus.waiting || order.status == OrderStatus.ready))
          Column(
            children: [
              if (order.status == OrderStatus.ready)
                CustomOutlinedIconButton(
                  function: _triggerQrScan,
                  icon: Icons.qr_code_2_outlined,
                  label: AppStringValues.pickUpOrder,
                  iconColor: Colors.green,
                ),
              if (order.status == OrderStatus.waiting)
                CustomOutlinedIconButton(
                  function: _triggerInfoSnackBar,
                  icon: Icons.qr_code_2_outlined,
                  label: AppStringValues.pickUpOrder,
                  iconColor: themeProvider.themeAdditionalData().unselectedColor!,
                  outlineColor: themeProvider.themeAdditionalData().unselectedColor!,
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
        //           _resultBtn(OrderStatus.waiting, 'Objednat znovu',
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
