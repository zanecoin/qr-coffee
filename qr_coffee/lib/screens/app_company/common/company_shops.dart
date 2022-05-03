import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/add_shop.dart';
import 'package:qr_coffee/screens/app_company/common/shop_tile.dart';
import 'package:qr_coffee/service/database_service/shop_database.dart';
import 'package:qr_coffee/service/database_service/user_database.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class CompanyShops extends StatefulWidget {
  const CompanyShops({Key? key}) : super(key: key);
  @override
  _CompanyShopsState createState() => _CompanyShopsState();
}

class _CompanyShopsState extends State<CompanyShops> {
  @override
  Widget build(BuildContext context) {
    final userFromAuth = Provider.of<UserFromAuth?>(context);
    final company = Provider.of<Company>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (company.companyID != '') {
      return StreamBuilder2<List<Shop>, UserData>(
        streams: Tuple2(
          ShopDatabase(companyID: company.companyID).shopList,
          UserDatabase(userID: userFromAuth!.userID).userData,
        ),
        builder: (context, snapshots) {
          if (snapshots.item1.hasData && snapshots.item2.hasData) {
            List<Shop> shopList = snapshots.item1.data!;
            UserData userData = snapshots.item2.data!;

            return Scaffold(
              backgroundColor: themeProvider.themeData().backgroundColor,
              appBar: customAppBar(
                context,
                title: Text(
                  AppStringValues.app_name,
                  style: TextStyle(
                    fontFamily: 'Galada',
                    fontSize: 30,
                    color: themeProvider.themeAdditionalData().textColor,
                  ),
                ),
                type: 3,
                actions: [if (userData.role == UserRole.admin) _addShop(company, themeProvider)],
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

  Widget _shopList(List<Shop> shopList, UserRole role, Company company) {
    return SizedBox(
      child: ListView.builder(
        itemBuilder: (context, index) => ShopTile(
          shop: shopList[index],
          role: role,
          company: company,
          hasSoldoutProducts: shopList[index].soldoutProducts.length > 0 ? true : false,
        ),
        itemCount: shopList.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget _addShop(Company company, ThemeProvider themeProvider) {
    return IconButton(
      onPressed: () => Navigator.push(
          context, new MaterialPageRoute(builder: (context) => AddShop(company: company))),
      icon: Icon(
        Icons.add_business_outlined,
        size: 30,
        color: themeProvider.themeAdditionalData().textColor,
      ),
    );
  }
}
