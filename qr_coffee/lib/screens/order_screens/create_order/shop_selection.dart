import 'package:flutter/material.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/screens/app_company/common/shop_tile.dart';
import 'package:qr_coffee/service/database_service/shop_database.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class ShopSelection extends StatefulWidget {
  const ShopSelection({Key? key, required this.databaseImages}) : super(key: key);
  final List<Map<String, dynamic>> databaseImages;

  @override
  _ShopSelectionState createState() => _ShopSelectionState();
}

class _ShopSelectionState extends State<ShopSelection> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Shop>>(
      stream: ShopDatabase(companyID: 'c9wzSTR2HEnYxmgEC8Wl').shopList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Shop> shopList = snapshot.data!;

          return Scaffold(
            appBar: customAppBar(
              context,
              title: Text(AppStringValues.orderPlace, style: TextStyle(fontSize: 16)),
              type: 1,
            ),
            body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (shopList.isNotEmpty) _shopList(shopList),
                    if (shopList.isEmpty) Center(child: Text(AppStringValues.noShops)),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }

  Widget _shopList(List<Shop> shopList) {
    return SizedBox(
      child: ListView.builder(
        itemBuilder: (context, index) => ShopTile(
          shop: shopList[index],
          role: 'customer',
          databaseImages: widget.databaseImages,
        ),
        itemCount: shopList.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }
}
