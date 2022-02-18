import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/add_shop.dart';
import 'package:qr_coffee/screens/app_company/shop_tile.dart';
import 'package:qr_coffee/service/database_service/shop_database.dart';
import 'package:qr_coffee/service/database_service/user_database.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class CompanyShops extends StatefulWidget {
  const CompanyShops({Key? key, required this.databaseImages}) : super(key: key);
  final List<Map<String, dynamic>> databaseImages;

  @override
  _CompanyShopsState createState() => _CompanyShopsState();
}

class _CompanyShopsState extends State<CompanyShops> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final company = Provider.of<Company>(context);

    if (company.uid != '') {
      return StreamBuilder2<List<Shop>, UserData>(
        streams: Tuple2(
          ShopDatabase(companyId: company.uid).shopList,
          UserDatabase(uid: user!.uid).userData,
        ),
        builder: (context, snapshots) {
          if (snapshots.item1.hasData && snapshots.item2.hasData) {
            List<Shop> shopList = snapshots.item1.data!;
            UserData userData = snapshots.item2.data!;

            return Scaffold(
              appBar: customAppBar(
                context,
                title: Text(
                  AppStringValues.app_name,
                  style: TextStyle(fontFamily: 'Galada', fontSize: 30),
                ),
                type: 3,
                actions: [if (userData.role == 'admin') _add(company)],
              ),
              body: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //_filterDropDown(),
                      //CustomDivider(),
                      if (shopList.isNotEmpty) _shopList(shopList, userData.role, company),
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
    } else {
      return Loading();
    }
  }

  Widget _shopList(List<Shop> shopList, String role, Company company) {
    return SizedBox(
      child: ListView.builder(
        itemBuilder: (context, index) => ShopTile(
          shop: shopList[index],
          role: role,
          databaseImages: widget.databaseImages,
          company: company,
        ),
        itemCount: shopList.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget _add(Company company) {
    return IconButton(
      onPressed: () => Navigator.push(
          context, new MaterialPageRoute(builder: (context) => AddShop(company: company))),
      icon: Icon(Icons.add_business_outlined, size: 30),
    );
  }
}