import 'package:flutter/material.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class AdminShopDetails extends StatefulWidget {
  const AdminShopDetails({Key? key, required this.shop}) : super(key: key);

  final Shop shop;

  @override
  _AdminShopDetailsState createState() => _AdminShopDetailsState(shop: shop);
}

class _AdminShopDetailsState extends State<AdminShopDetails> {
  _AdminShopDetailsState({required this.shop});

  final Shop shop;

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();
  bool loading = false;
  String errorMessage = '';

  String address = '';
  String city = '';
  String openingHours = '';

  @override
  Widget build(BuildContext context) {
    double deviceWidth = Responsive.deviceWidth(context);

    return Scaffold(
      appBar: customAppBar(context, title: Text(CzechStrings.shopDetails)),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: deviceWidth > kDeviceUpperWidthTreshold ? 400 : Responsive.width(80, context),
            child: Form(
              key: _key,
              child: Column(
                children: [
                  SizedBox(height: Responsive.height(3, context)),
                  CustomCircleAvatar(icon: Icons.store),
                  SizedBox(height: Responsive.height(3, context)),
                  CustomTextField(
                    CzechStrings.address,
                    Icons.gps_fixed,
                    callback,
                    validation: validateAddress,
                    initVal: shop.address,
                  ),
                  CustomTextField(
                    CzechStrings.city,
                    Icons.location_city,
                    callback,
                    validation: validateCity,
                    initVal: shop.city,
                  ),
                  SizedBox(height: Responsive.height(2, context)),
                  Text(CzechStrings.openingHours, style: TextStyle(fontSize: 16)),
                  SizedBox(height: Responsive.height(1, context)),
                  Container(
                    child: Text(shop.openingHours, style: TextStyle(fontSize: 16)),
                    color: Colors.grey.shade200,
                    padding: EdgeInsets.all(10),
                  ),
                  SizedBox(height: Responsive.height(1, context)),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    width: Responsive.width(60, context),
                    child: ElevatedButton(
                      child: loading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              CzechStrings.confirmChanges,
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                      onPressed: updateShop,
                      style: customButtonStyle(),
                    ),
                  ),
                  SizedBox(height: Responsive.height(5, context)),
                  CustomDivider(indent: 0),
                  Container(
                    width: Responsive.width(60, context),
                    child: ElevatedButton(
                      child: loading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              CzechStrings.deleteShop,
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                      onPressed: () {
                        customAlertDialog(context, deleteShop);
                      },
                      style: customButtonStyle(color: Colors.red.shade500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TextFormField callback function.
  callback(varLabel, varValue) {
    formField[varLabel] = varValue;
  }

  deleteShop() {
    ShopDatabase().deleteShop(shop.uid);
  }

  updateShop() async {
    setState(() {
      loading = true;
      errorMessage = '';
    });

    FocusManager.instance.primaryFocus!.unfocus();

    if (_key.currentState!.validate()) {
      _key.currentState!.save();

      address = (formField[CzechStrings.address] ?? '').trim();
      city = (formField[CzechStrings.city] ?? '').trim();

      ShopDatabase().updateShopData(
          shop.uid, address, shop.coordinates, shop.active, city, shop.openingHours);
    } else {
      setState(() => loading = false);
    }
  }
}
