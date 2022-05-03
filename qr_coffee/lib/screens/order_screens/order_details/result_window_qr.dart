import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ResultWindow extends StatelessWidget {
  const ResultWindow({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    this.fontSize = 16.0,
  }) : super(key: key);

  final double fontSize;
  final String text;
  final Widget icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      width: 280.0,
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 5.0),
            Flexible(
              child: Text(text,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: themeProvider.themeAdditionalData().textColor,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultWindowChooser extends StatelessWidget {
  const ResultWindowChooser({
    Key? key,
    required this.order,
    required this.mode,
    required this.role,
  }) : super(key: key);

  final Order order;
  final String mode;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        if (order.status == OrderStatus.completed)
          ResultWindow(
            text: AppStringValues.orderCollected,
            color: themeProvider.themeAdditionalData().greenBannerColor!,
            icon: checkIcon(color: Colors.green.shade400),
          ),
        if (order.status == OrderStatus.abandoned)
          ResultWindow(
            text: AppStringValues.orderAbandoned,
            color: themeProvider.themeAdditionalData().orangeBannerColor!,
            icon: questionIcon(),
          ),
        if (order.status == OrderStatus.aborted)
          ResultWindow(
            text: AppStringValues.orderCancelled,
            color: themeProvider.themeAdditionalData().redBannerColor!,
            icon: errorIcon(),
          ),
        if (order.status == OrderStatus.pending)
          ResultWindow(
            text: AppStringValues.orderPending,
            color: themeProvider.themeAdditionalData().blueBannerColor!,
            icon: waitingIcon(),
          ),
        if (order.status == OrderStatus.withdraw)
          ResultWindow(
            text: role == UserRole.customer
                ? AppStringValues.withdrawPlease
                : AppStringValues.withdrawUser,
            color: themeProvider.themeAdditionalData().blueBannerColor!,
            icon: infoIcon(),
            fontSize: 13.0,
          ),
        if (order.status == OrderStatus.ready)
          ResultWindow(
            text: AppStringValues.orderReady,
            color: role == UserRole.customer
                ? themeProvider.themeAdditionalData().greenBannerColor!
                : themeProvider.themeAdditionalData().blueBannerColor!,
            icon: checkIcon(
              color: role == UserRole.customer ? Colors.green.shade400 : Colors.blue.shade400,
            ),
          ),
        if (mode == 'after-creation')
          if (order.status == OrderStatus.waiting)
            ResultWindow(
              text: AppStringValues.orderRecieved,
              color: themeProvider.themeAdditionalData().blueBannerColor!,
              icon: checkIcon(color: Colors.blue.shade400),
            ),
        if (mode == 'normal')
          if (order.status == OrderStatus.waiting)
            ResultWindow(
              text: AppStringValues.waitForReady,
              color: themeProvider.themeAdditionalData().blueBannerColor!,
              icon: checkIcon(color: Colors.blue.shade400),
            ),
      ],
    );
  }
}

class QrCard extends StatelessWidget {
  //const QrCard({Key? key, required this.order}) : super(key: key);

  //final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(40)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(0.0, 0.0),
              blurRadius: 15.0,
              spreadRadius: 5.0),
        ],
      ),
      child: Column(
        children: [
          //QrImage(data: order.orderID, size: 220.0),
          QrImage(data: 'QR Coffee', size: 220.0),
          Text(
            //'${AppStringValues.orderCode}: "${order.orderID.substring(0, 6).toUpperCase()}"',
            'QR Coffee',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
