import 'package:flutter/material.dart';
import 'package:qr_coffee/models/item.dart';
import 'package:qr_coffee/screens/order_screens/coffee_inventory.dart';
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
  final List<Item> items;
  final TabController controller;
  final Function onItemTap;

  @override
  Widget build(BuildContext context) {
    List<String> choices = [CzechStrings.drink, CzechStrings.food];
    final double deviceWidth = Responsive.deviceWidth(context);
    final bool largeDevice =
        deviceWidth > kDeviceUpperWidthTreshold ? true : false;

    return TabBarView(
      controller: controller,
      children: choices
          .map((choice) => _orderGrid(
                items,
                choice,
                databaseImages,
                largeDevice,
              ))
          .toList(),
    );
  }

  Widget _orderGrid(items, choice, databaseImages, largeDevice) {
    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      children: _filter(items, choice)
          .map((item) => CoffeeKindTile(
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

  List<Item> _filter(List<Item> items, String choice) {
    List<Item> result = [];
    for (var item in items) {
      if (item.type == 'drink' && choice == CzechStrings.drink) {
        result.add(item);
      }
      if (item.type == 'food' && choice == CzechStrings.food) {
        result.add(item);
      }
    }
    return result;
  }
}
