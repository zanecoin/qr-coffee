import 'package:flutter/material.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/screens/order_screens/product_tile.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/custom_snackbar.dart';

class OrderMenu extends StatefulWidget {
  const OrderMenu({
    Key? key,
    required this.databaseImages,
    required this.items,
    required this.controller,
    required this.onItemTap,
    required this.shop,
  }) : super(key: key);

  final List<Map<String, dynamic>> databaseImages;
  final List<Product> items;
  final TabController controller;
  final Function onItemTap;
  final Shop shop;

  @override
  State<OrderMenu> createState() => _OrderMenuState();
}

class _OrderMenuState extends State<OrderMenu> {
  late BuildContext screenContext;

  @override
  Widget build(BuildContext context) {
    screenContext = context;
    List<String> choices = [AppStringValues.drink, AppStringValues.food];
    return TabBarView(
      controller: widget.controller,
      children: choices
          .map((choice) => _orderGrid(widget.items, choice, widget.databaseImages, context))
          .toList(),
    );
  }

  Widget _orderGrid(items, choice, databaseImages, BuildContext context) {
    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      children: _filter(items, choice)
          .map((item) => ProductTile(
                item: item,
                onItemTap: widget.shop.soldoutProducts.contains(item.productID)
                    ? _showErrorSnackbar
                    : widget.onItemTap,
                onItemLongPress: null,
                imageUrl: chooseUrl(databaseImages, item.pictureURL),
                shopID: widget.shop.shopID,
                companyID: widget.shop.companyID,
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

  _showErrorSnackbar(Product product) {
    customSnackbar(context: screenContext, text: AppStringValues.productIsSoldout);
  }
}
