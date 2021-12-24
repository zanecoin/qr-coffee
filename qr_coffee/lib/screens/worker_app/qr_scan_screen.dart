import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';
import 'package:qr_coffee/shared/strings.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String barcode = CzechStrings.scanQr;
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
      stream: DatabaseService().activeOrderList,
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
                    label: Text(CzechStrings.back),
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
        child: Text(
          barcode,
          maxLines: 3,
        ),
      );

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderWidth: 10,
          borderLength: 20,
          cutOutSize: min(
              Responsive.width(80, context), Responsive.height(80, context)),
        ),
      );

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream.listen((barcode) async {
      Order? order;

      for (var ord in activeOrders) {
        if (ord.orderId == barcode.code) {
          order = ord;
          break;
        }
      }

      if (order != null) {
        if (order.status == 'READY') {
          String status = 'COMPLETED';
          await DatabaseService().createPassiveOrder(
            status,
            order.items,
            order.price,
            order.pickUpTime,
            order.username,
            order.place,
            order.orderId,
            order.userId,
            order.day,
            order.triggerNum,
          );

          await DatabaseService().deleteActiveOrder(order.orderId);
        }

        Navigator.pop(context);
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => OrderDetails(
              order: order!,
              role: 'worker-on',
              mode: 'normal',
            ),
          ),
        );

        if (order.status == 'ACTIVE') {
          await DatabaseService().triggerOrder(order.orderId, 1);
          print('trigger: 1');
          Future.delayed(Duration(milliseconds: 3000));
          await DatabaseService().triggerOrder(order.orderId, 0);
          print('trigger: 0');
        }
      } else {
        setState(() => this.barcode = CzechStrings.orderNotFound);
      }
    });
  }
}
