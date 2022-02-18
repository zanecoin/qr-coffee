import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/product_update_form.dart';
import 'package:qr_coffee/screens/order_screens/product_tile.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class CompanyProducts extends StatefulWidget {
  const CompanyProducts({Key? key, required this.databaseImages}) : super(key: key);

  final List<Map<String, dynamic>> databaseImages;

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
    final double deviceWidth = Responsive.deviceWidth(context);
    final bool largeDevice = deviceWidth > kDeviceUpperWidthTreshold ? true : false;
    final company = Provider.of<Company>(context);
    final user = Provider.of<User?>(context);

    if (company.uid != '') {
      return StreamBuilder2<List<Product>, UserData>(
        streams: Tuple2(
          ProductDatabase(uid: company.uid).products,
          UserDatabase(uid: user!.uid).userData,
        ),
        builder: (context, snapshots) {
          if (snapshots.item1.hasData && snapshots.item2.hasData) {
            List<Product> products = snapshots.item1.data!;
            UserData userData = snapshots.item2.data!;

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  AppStringValues.app_name,
                  style: TextStyle(fontFamily: 'Galada', fontSize: 30),
                ),
                centerTitle: true,
                elevation: 0,
                bottom: TabBar(
                  controller: controller,
                  labelPadding: EdgeInsets.symmetric(vertical: 0),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey.shade300,
                  indicatorColor: Colors.black,
                  tabs: choices.map<Widget>((choice) => Tab(text: choice)).toList(),
                ),
                actions: [if (userData.role == 'admin') _add(company)],
              ),
              body: TabBarView(
                controller: controller,
                children: choices
                    .map((choice) =>
                        _orderGrid(userData, products, choice, widget.databaseImages, largeDevice))
                    .toList(),
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
        context, new MaterialPageRoute(builder: (context) => ProductUpdateForm(product: product)));
  }

  _tempFunc(Product product) {
    customSnackbar(
        context: context, text: 'Funkce "položka vyprodána" ještě není implementovaná.*');
  }

  Widget _orderGrid(
      UserData userData, List<Product> items, choice, databaseImages, bool largeDevice) {
    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      children: _filter(items, choice)
          .map((item) => ProductTile(
                item: item,
                onItemTap: userData.role == 'admin' ? _pushDetails : _tempFunc,
                imageUrl: chooseUrl(databaseImages, item.picture),
                largeDevice: largeDevice,
              ))
          .toList(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: largeDevice ? 4 : 2,
      ),
    );
  }

  List<Product> _filter(List<Product> items, String choice) {
    List<Product> result = [];
    for (var item in items) {
      if (item.type == 'drink' && choice == AppStringValues.drink) {
        result.add(item);
      }
      if (item.type == 'food' && choice == AppStringValues.food) {
        result.add(item);
      }
    }
    return result;
  }

  _add(Company company) {
    return IconButton(
      onPressed: () => customSnackbar(
          context: context, text: 'Funkce "přidat produkt" ještě není implementovaná.*'),
      icon: Icon(Icons.add_box_outlined, size: 30),
    );
  }
}
