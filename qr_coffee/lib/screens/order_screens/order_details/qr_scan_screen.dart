import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details_customer.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
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
            order.orderID,
            order.userID,
            order.shopID,
            order.companyID,
            order.day,
          );

          await CustomerOrderDatabase(userID: order.userID).createPassiveOrder(
            status,
            order.items,
            order.price,
            order.pickUpTime,
            order.username,
            order.shop,
            order.company,
            order.orderID,
            order.shopID,
            order.companyID,
            order.day,
          );

          await CompanyOrderDatabase().deleteActiveOrder(order.orderID);
          await CustomerOrderDatabase(userID: order.userID).deleteActiveOrder(order.orderID);
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
      } else {
        setState(() => this.barcode = AppStringValues.wrongQr);
      }
    });
  }
}
