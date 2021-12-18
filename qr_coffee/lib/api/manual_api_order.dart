import 'dart:convert';
import 'package:qr_coffee/models/item.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/screens/order_screens/order_inventory.dart';
import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_coffee/models/album.dart';
import 'package:webview_flutter/webview_flutter.dart';

String prodID = '4142611';
String prodSEC = '82afcdd4b99abce2591a7e685afe7f06';
String sndID = '425359';
String sndSEC = '42d8e74e6a0215331158b69911865a9f';
String pubID = '145227';
String pubSEC = '12f071174cb7eb79d4aac5bc2f07563f';

launchPaymentGateway(
  BuildContext context,
  int price,
  List<Item> items,
  Order order,
) async {
  // GET AUTHORIZATION
  final response = await http.post(
    Uri.parse(
        'https://secure.snd.payu.com/pl/standard/user/oauth/authorize?grant_type=client_credentials&client_id=$sndID&client_secret=$sndSEC'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
  );

  String token = '';
  if (response.statusCode == 200) {
    print(jsonDecode(response.statusCode.toString()));
    print(jsonDecode(response.body).toString());
    token = Album.fromJson(jsonDecode(response.body)).access_token;
  } else {
    throw Exception('Failed to create album.');
  }

  // GET PAYMENT METHODS
  final response2 = await http.get(
    Uri.parse('https://secure.snd.payu.com/api/v2_1/paymethods/'),
    headers: <String, String>{
      'Authorization': 'Bearer $token',
    },
  );
  print(jsonDecode(response2.statusCode.toString()));
  print(jsonDecode(response2.body).toString());

  // GET GATEWAY URL
  final response3 = await http.post(
    Uri.parse('https://secure.snd.payu.com/api/v2_1/orders/'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      'notifyUrl':
          'https://us-central1-cafe-app-937c9.cloudfunctions.net/gatewayNotification',
      'continueUrl': 'https://www.herself.cz/',
      'customerIp': '127.0.0.1',
      'merchantPosId': '$sndID',
      'description': 'QR Coffee',
      'currencyCode': 'PLN',
      'totalAmount': '${price * 100}',
      'extOrderId': '${order.orderId}',
      'products': [
        {'name': 'Wireless mouse', 'unitPrice': '15000', 'quantity': '1'},
        {'name': 'HDMI cable', 'unitPrice': '6000', 'quantity': '1'}
      ],
      // 'payMethods': {
      //   'payMethod': {
      //     'type': "CARD_TOKEN",
      //   }
      // }
    }),
  );

  String url = '';
  String orderId = '';

  if (response3.statusCode == 302 || response3.statusCode == 400) {
    print(jsonDecode(response3.statusCode.toString()));
    print(jsonDecode(response3.body).toString());
    url = Address.fromJson(jsonDecode(response3.body)).redirectUri;
    orderId = Address.fromJson(jsonDecode(response3.body)).orderId;
  } else {
    throw Exception('Failed to create album.');
  }

  // LAUNCH WEBVIEW
  if (url == '') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirect error.'),
        duration: Duration(milliseconds: 2000),
      ),
    );
  } else {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => PaymentWebView(
          url: url,
          order: order,
        ),
      ),
    );
  }
}

class PaymentWebView extends StatefulWidget {
  final String url;
  final Order order;
  PaymentWebView({Key? key, required this.url, required this.order})
      : super(key: key);

  @override
  _PaymentWebViewState createState() =>
      _PaymentWebViewState(url: url, order: order);
}

class _PaymentWebViewState extends State<PaymentWebView> {
  final String url;
  final Order order;
  _PaymentWebViewState({required this.url, required this.order});

  late WebViewController controller;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: customAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: WebView(
                initialUrl: url,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (controller) {
                  this.controller = controller;
                },
                onPageStarted: (newUrl) {
                  if (newUrl == 'https://www.herself.cz/') {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (context) => UserOrder(
                          role: 'customer',
                          order: order,
                          mode: 'after-creation',
                        ),
                      ),
                    );
                  }
                },
                onProgress: (progress) => setState(() {
                  this.progress = progress / 100;
                }),
              ),
            ),
            if (progress != 1)
              LinearProgressIndicator(
                value: progress,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
}
