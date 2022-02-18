import 'package:flutter/material.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';

class CustomPlaceDropdown extends StatefulWidget {
  CustomPlaceDropdown(
    this.shops,
    this.filter,
    this.callback,
    this.savedShop,
  );

  final List<Shop> shops;
  final bool filter;
  final Function callback;
  final String? savedShop;

  @override
  State<CustomPlaceDropdown> createState() => _CustomPlaceDropdownState(
        shops: shops,
        filter: filter,
        callback: callback,
        savedShop: savedShop,
      );
}

class _CustomPlaceDropdownState extends State<CustomPlaceDropdown> {
  _CustomPlaceDropdownState({
    required this.shops,
    required this.filter,
    required this.callback,
    required this.savedShop,
  });

  final List<Shop> shops;
  final bool filter;
  final Function callback;
  final String? savedShop;

  String? _currentShop;

  @override
  void initState() {
    super.initState();
    _currentShop = savedShop;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = Responsive.deviceWidth(context);
    List<Shop> filteredShops = [];

    if (filter) {
      for (var shop in shops) {
        if (shop.active) {
          filteredShops.add(shop);
        }
      }
    } else {
      for (var shop in shops) {
        filteredShops.add(shop);
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: deviceWidth > kDeviceUpperWidthTreshold ? Responsive.width(60, context) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                hint: Text(
                  filteredShops.length > 0 ? AppStringValues.choosePlace : AppStringValues.noPlace,
                ),
                value: _currentShop,
                items: filteredShops.map((place) {
                  return DropdownMenuItem(
                    child: Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: place.active
                              ? (filter ? Colors.black : Colors.grey)
                              : (filter ? Colors.grey : Colors.black),
                        ),
                        Text(
                          cutTextIfNeccessary(place.address, Responsive.textTreshold(context)),
                          style: TextStyle(
                            color: place.active
                                ? (filter ? Colors.black : Colors.grey)
                                : (filter ? Colors.grey : Colors.black),
                          ),
                        ),
                      ],
                    ),
                    value: place.address,
                  );
                }).toList(),
                onChanged: (val) {
                  _currentShop = val.toString();
                  callback(_getShopObject(val.toString(), filteredShops));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Shop? _getShopObject(String address, List<Shop> shops) {
    Shop? shop;

    for (var item in shops) {
      if (item.address == address) {
        shop = item;
      }
    }

    return shop;
  }
}
