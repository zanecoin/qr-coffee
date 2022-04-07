import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/customer.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/screens/order_screens/order_details/result_function.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class ResultButton extends StatelessWidget {
  const ResultButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.order,
    required this.status,
    required this.previousContext,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final Color color;
  final Order order;
  final OrderStatus status;
  final BuildContext previousContext;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return StreamBuilder<Customer>(
      stream: CustomerDatabase(userID: order.userID).customer,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Customer customer = snapshot.data!;

          return TextButton(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 70, color: color),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.themeAdditionalData().textColor,
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () {
              if (status == OrderStatus.waiting) {
                repeatOrder(order, status, previousContext);
              } else if (status == OrderStatus.ready) {
                updateOrderStatus(order, status);
                customSnackbar(
                  context: context,
                  text: '${AppStringValues.orderStatusChange}${AppStringValues.orderReady}',
                );
              } else {
                moveOrderToPassive(order, status, customer);
                if (status == OrderStatus.completed)
                  customSnackbar(
                    context: context,
                    text: '${AppStringValues.orderStatusChange}${AppStringValues.orderCollected}',
                  );
                if (status == OrderStatus.abandoned)
                  customSnackbar(
                    context: context,
                    text: '${AppStringValues.orderStatusChange}${AppStringValues.orderAbandoned}',
                  );
                if (status == OrderStatus.aborted) {
                  customSnackbar(
                    context: context,
                    text: '${AppStringValues.orderStatusChange}${AppStringValues.orderCancelled}',
                  );
                }
              }
            },
          );
        } else {
          return Loading();
        }
      },
    );
  }
}
