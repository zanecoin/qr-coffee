import 'dart:convert';
import 'package:http/http.dart';
import 'package:qr_coffee/api/model/album.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/screens/order_screens/order_details/order_details_customer.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_coffee/shared/widgets/custom_snackbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

String prodID = '4142611';
String prodSEC = '82afcdd4b99abce2591a7e685afe7f06';
String sndID = '425359';
String sndSEC = '42d8e74e6a0215331158b69911865a9f';
String pubID = '145227';
String pubSEC = '12f071174cb7eb79d4aac5bc2f07563f';

String authUrl =
    'https://secure.snd.payu.com/pl/standard/user/oauth/authorize?grant_type=client_credentials&client_id=$sndID&client_secret=$sndSEC';

String methodsUrl = 'https://secure.snd.payu.com/api/v2_1/paymethods/';

String postOrderUrl = 'https://secure.snd.payu.com/api/v2_1/orders/';

String notifyUrl = 'https://us-central1-cafe-app-937c9.cloudfunctions.net/gatewayNotification';

String continueUrl = 'https://www.herself.cz/';

launchPaymentGateway(BuildContext context, int price, List<Product> items, Order order) async {
  Response response;

  // Get authorization.
  response = await http.post(
    Uri.parse(authUrl),
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
    customSnackbar(
      context: context,
      text: '${AppStringValues.paymentError} ${response.statusCode}',
    );
    return null;
  }

  // Get payment methods.
  response = await http.get(
    Uri.parse(methodsUrl),
    headers: <String, String>{
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    print(jsonDecode(response.statusCode.toString()));
    print(jsonDecode(response.body).toString());
  } else {
    customSnackbar(
      context: context,
      text: '${AppStringValues.paymentError} ${response.statusCode}',
    );
    return null;
  }

  // Get gateway URL.
  response = await http.post(
    Uri.parse(postOrderUrl),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      'notifyUrl': notifyUrl,
      'continueUrl': continueUrl,
      'customerIp': '127.0.0.1',
      'merchantPosId': '$sndID',
      'description': 'QR Coffee',
      'currencyCode': 'PLN',
      'totalAmount': '${price * 100}',
      'extOrderId': '${order.orderId}_${order.companyId}_${order.userId}',
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
  //String orderId = '';

  if (response.statusCode == 302 || response.statusCode == 400) {
    print(jsonDecode(response.statusCode.toString()));
    print(jsonDecode(response.body).toString());
    url = Address.fromJson(jsonDecode(response.body)).redirectUri;
    //orderId = Address.fromJson(jsonDecode(response3.body)).orderId;
  } else {
    customSnackbar(
      context: context,
      text: '${AppStringValues.paymentError} ${response.statusCode}',
    );
    return null;
  }

  // Launch WebView.
  if (url == '') {
    customSnackbar(context: context, text: 'Redirect error.');
  } else {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => PaymentWebView(url: url, order: order),
      ),
    );
  }
}

class PaymentWebView extends StatefulWidget {
  final String url;
  final Order order;
  PaymentWebView({Key? key, required this.url, required this.order}) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState(url: url, order: order);
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
                  if (newUrl == continueUrl) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailsCustomer(order: order, mode: 'after-creation'),
                      ),
                    );
                    customSnackbar(context: context, text: AppStringValues.orderCreationSuccess);
                  }
                },
                onProgress: (progress) => setState(() => this.progress = progress / 100),
              ),
            ),
            if (progress != 1) LinearProgressIndicator(value: progress, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
