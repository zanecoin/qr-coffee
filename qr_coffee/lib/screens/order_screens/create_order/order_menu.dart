import 'package:flutter/material.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/screens/order_screens/product_tile.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';

class OrderMenu extends StatelessWidget {
  const OrderMenu({
    Key? key,
    required this.databaseImages,
    required this.items,
    required this.controller,
    required this.onItemTap,
  }) : super(key: key);

  final List<Map<String, dynamic>> databaseImages;
  final List<Product> items;
  final TabController controller;
  final Function onItemTap;

  @override
  Widget build(BuildContext context) {
    List<String> choices = [AppStringValues.drink, AppStringValues.food];
    final double deviceWidth = Responsive.deviceWidth(context);
    final bool largeDevice = deviceWidth > kDeviceUpperWidthTreshold ? true : false;

    return TabBarView(
      controller: controller,
      children:
          choices.map((choice) => _orderGrid(items, choice, databaseImages, largeDevice)).toList(),
    );
  }

  Widget _orderGrid(items, choice, databaseImages, largeDevice) {
    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      children: _filter(items, choice)
          .map((item) => ProductTile(
                item: item,
                onItemTap: onItemTap,
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
}
