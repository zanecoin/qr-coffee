import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details_customer.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';
import 'package:qr_coffee/shared/strings.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key, required this.order}) : super(key: key);

  final Order order;

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String barcode = AppStringValues.scanQr;
  List<Order> activeOrders = [];

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();

    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: CompanyOrderDatabase().activeOrderList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          activeOrders = snapshot.data!;

          return Scaffold(
            body: Stack(
              alignment: Alignment.center,
              children: [
                buildQrView(context),
                Positioned(
                  bottom: Responsive.height(16, context),
                  child: buildResult(),
                ),
                Positioned(
                  top: Responsive.height(8, context),
                  left: Responsive.width(4, context),
                  child: TextButton.icon(
                    label: Text(AppStringValues.back),
                    icon: Icon(Icons.arrow_back_ios, size: 22),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white24,
                      primary: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }

  Widget buildResult() => Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(barcode, maxLines: 3),
      );

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderWidth: 10,
          borderLength: 20,
          cutOutSize: min(Responsive.width(80, context), Responsive.height(80, context)),
        ),
      );

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream.listen((barcode) async {
      Order order = widget.order;

      if (barcode.code == 'QR Coffee') {
        if (order.status == 'READY') {
          String status = 'COMPLETED';
          await CompanyOrderDatabase().createPassiveOrder(
            status,
            order.items,
            order.price,
            order.pickUpTime,
            order.username,
            order.shop,
            order.company,
            order.orderId,
            order.userId,
            order.shopId,
            order.companyId,
            order.day,
            order.triggerNum,
          );

          await UserOrderDatabase(uid: order.userId).createPassiveOrder(
            status,
            order.items,
            order.price,
            order.pickUpTime,
            order.username,
            order.shop,
            order.company,
            order.orderId,
            order.userId,
            order.shopId,
            order.companyId,
            order.day,
            order.triggerNum,
          );

          await CompanyOrderDatabase().deleteActiveOrder(order.orderId);
          await UserOrderDatabase(uid: order.userId).deleteActiveOrder(order.orderId);
        }

        if (!mounted) return;
        Navigator.pop(context);

        // Mode 'qr' is here to pass the info that back arrow needs to do double pop(context).
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => OrderDetailsCustomer(order: order, mode: 'qr'),
          ),
        );

        if (order.status == 'ACTIVE') {
          await UserOrderDatabase(uid: order.userId).triggerOrder(order.orderId, 1);
          print('trigger: 1');
          Future.delayed(Duration(milliseconds: 3000));
          await UserOrderDatabase(uid: order.userId).triggerOrder(order.orderId, 0);
          print('trigger: 0');
        }
      } else {
        setState(() => this.barcode = AppStringValues.wrongQr);
      }
    });
  }
}
