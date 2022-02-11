import 'dart:math';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/shop_details.dart';
import 'package:qr_coffee/screens/app_company/app_worker/worker_home_body.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/strings.dart';

class ShopTile extends StatelessWidget {
  ShopTile({required this.shop, required this.role, required this.databaseImages});
  final Shop shop;
  final String role;
  final List<Map<String, dynamic>> databaseImages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: InkWell(
          onTap: () {
            if (role == 'admin') {
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => AdminShopDetails(shop: shop)),
              );
            } else {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) =>
                          WorkerHomeBody(shop: shop, databaseImages: databaseImages)));
            }
          },
          child: Container(
            height: max(Responsive.height(15, context), 90),
            width: Responsive.width(67, context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: Offset(1, 1),
                  blurRadius: 15,
                  spreadRadius: 0,
                )
              ],
            ),
            child: Center(
              child: Row(
                children: [
                  SizedBox(width: Responsive.width(6, context)),
                  Icon(Icons.store_outlined, size: 40),
                  SizedBox(width: Responsive.width(6, context)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.address.length < Responsive.textTreshold(context)
                            ? '${shop.address}'
                            : '${shop.address.substring(0, Responsive.textTreshold(context))}...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(shop.city),
                      Text(shop.active ? CzechStrings.active : CzechStrings.inactive),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
