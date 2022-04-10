import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/product_detail.dart';
import 'package:qr_coffee/screens/order_screens/product_tile.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class CompanyProducts extends StatefulWidget {
  const CompanyProducts({Key? key}) : super(key: key);
  @override
  State<CompanyProducts> createState() => _CompanyProductsState();
}

class _CompanyProductsState extends State<CompanyProducts> with SingleTickerProviderStateMixin {
  late TabController controller;
  List<String> choices = [AppStringValues.drink, AppStringValues.food];

  // Upper tab controller.
  @override
  void initState() {
    super.initState();
    controller = TabController(length: choices.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> choices = [AppStringValues.drink, AppStringValues.food];
    final company = Provider.of<Company>(context);
    final userFromAuth = Provider.of<UserFromAuth?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (company.companyID != '') {
      return StreamBuilder2<List<Product>, UserData>(
        streams: Tuple2(
          ProductDatabase(companyID: company.companyID).products,
          UserDatabase(userID: userFromAuth!.userID).userData,
        ),
        builder: (context, snapshots) {
          if (snapshots.item1.hasData && snapshots.item2.hasData) {
            List<Product> products = snapshots.item1.data!;
            UserData userData = snapshots.item2.data!;

            return Scaffold(
              backgroundColor: themeProvider.themeData().backgroundColor,
              appBar: AppBar(
                backgroundColor: themeProvider.themeData().backgroundColor,
                title: Text(
                  userData.role == UserRole.worker
                      ? AppStringValues.markSoldout
                      : AppStringValues.app_name,
                  style: userData.role == UserRole.worker
                      ? TextStyle(
                          fontSize: 13.0,
                          color: themeProvider.themeAdditionalData().textColor,
                        )
                      : TextStyle(
                          fontFamily: 'Galada',
                          fontSize: 30.0,
                          color: themeProvider.themeAdditionalData().textColor,
                        ),
                ),
                leading: userData.role == UserRole.worker ? _backArrow(themeProvider) : null,
                centerTitle: true,
                elevation: 0,
                bottom: TabBar(
                  controller: controller,
                  labelPadding: EdgeInsets.symmetric(vertical: 0),
                  labelColor: themeProvider.themeAdditionalData().textColor,
                  unselectedLabelColor: themeProvider.themeAdditionalData().unselectedColor,
                  indicatorColor: themeProvider.themeAdditionalData().textColor,
                  tabs: choices.map<Widget>((choice) => Tab(text: choice)).toList(),
                ),
                actions: [if (userData.role == UserRole.admin) _add(company, themeProvider)],
              ),
              body: FutureBuilder(
                future: loadImages('pictures/products/${company.companyID}/'),
                builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> picSnapshot) {
                  if (picSnapshot.connectionState == ConnectionState.done) {
                    return TabBarView(
                      controller: controller,
                      children: choices
                          .map(
                              (choice) => _orderGrid(userData, products, choice, picSnapshot.data!))
                          .toList(),
                    );
                  } else {
                    return Loading();
                  }
                },
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

  _pushDetails(Product product) {
    Navigator.push(
        context, new MaterialPageRoute(builder: (context) => ProductDetail(product: product)));
  }

  _tempFunc(Product product) {
    customSnackbar(
        context: context, text: 'Funkce "položka vyprodána" ještě není implementovaná.*');
  }

  Widget _backArrow(ThemeProvider themeProvider) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        size: 22,
        color: themeProvider.themeAdditionalData().textColor,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _orderGrid(UserData userData, List<Product> items, choice, databaseImages) {
    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      children: _filter(items, choice)
          .map((item) => ProductTile(
                item: item,
                onItemTap: userData.role == UserRole.admin ? _pushDetails : _tempFunc,
                imageUrl: chooseUrl(databaseImages, item.pictureURL),
              ))
          .toList(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isLargeDevice(context) ? 4 : 2,
      ),
    );
  }

  List<Product> _filter(List<Product> items, String choice) {
    List<Product> result = [];
    for (var item in items) {
      if (item.type == ProductType.drink && choice == AppStringValues.drink) {
        result.add(item);
      }
      if (item.type == ProductType.food && choice == AppStringValues.food) {
        result.add(item);
      }
    }
    return result;
  }

  _add(Company company, ThemeProvider themeProvider) {
    return IconButton(
      onPressed: () => customSnackbar(
          context: context, text: 'Funkce "přidat produkt" ještě není implementovaná.*'),
      icon: Icon(
        Icons.add_box_outlined,
        size: 30,
        color: themeProvider.themeAdditionalData().textColor,
      ),
    );
  }
}
