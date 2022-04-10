import 'dart:math';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/shop_details.dart';
import 'package:qr_coffee/screens/app_company/app_worker/worker_home_body/worker_home_body.dart';
import 'package:qr_coffee/screens/order_screens/create_order/create_order_screen.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class ShopTile extends StatelessWidget {
  ShopTile({
    required this.shop,
    required this.role,
    this.company,
  });

  final Shop shop;
  final UserRole role;
  final Company? company;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Card(
        color: themeProvider.themeAdditionalData().containerColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            if (role == UserRole.admin) {
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => StreamProvider(
                    create: (context) => CompanyDatabase(companyID: company!.companyID).company,
                    initialData: Company.initialData(),
                    catchError: (_, __) => Company.initialData(),
                    child: AdminShopDetails(shop: shop),
                  ),
                ),
              );
            } else if (role == UserRole.worker) {
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => StreamProvider(
                    create: (context) => CompanyDatabase(companyID: company!.companyID).company,
                    initialData: Company.initialData(),
                    catchError: (_, __) => Company.initialData(),
                    child: WorkerHomeBody(shop: shop),
                  ),
                ),
              );
            } else {
              if (_getShopOpenStatus()[2]) {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => CreateOrderScreen(shop: shop),
                  ),
                );
              } else {
                customSnackbar(context: context, text: AppStringValues.shopClosed);
              }
            }
          },
          child: Container(
            height: max(Responsive.height(15, context), 90),
            width: Responsive.width(67, context),
            decoration: BoxDecoration(
                color: themeProvider.themeAdditionalData().containerColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: themeProvider.themeAdditionalData().shadow),
            child: Center(
              child: Row(
                children: [
                  SizedBox(width: Responsive.width(6, context)),
                  Icon(Icons.store, size: 40, color: themeProvider.themeAdditionalData().textColor),
                  SizedBox(width: Responsive.width(6, context)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (role == UserRole.customer)
                        Text(
                          shop.company,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeProvider.themeAdditionalData().textColor,
                          ),
                        ),
                      Text(
                        cutTextIfNeccessary(shop.address, Responsive.textTreshold(context)),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: themeProvider.themeAdditionalData().textColor,
                        ),
                      ),
                      Text(
                        shop.city,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: themeProvider.themeAdditionalData().textColor,
                        ),
                      ),
                      Text(
                        _getShopOpenStatus()[0],
                        style: TextStyle(color: _getShopOpenStatus()[1]),
                      ),
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

  List<dynamic> _getShopOpenStatus() {
    int presentTime =
        int.parse(DateFormat('yyyyMMddHHmmss').format(DateTime.now()).substring(8, 12));
    int lowerBoundary =
        int.parse('${shop.openingHours.substring(0, 2)}${shop.openingHours.substring(3, 5)}');
    int upperBoundary =
        int.parse('${shop.openingHours.substring(6, 8)}${shop.openingHours.substring(9, 11)}');
    if (presentTime > lowerBoundary && presentTime < upperBoundary) {
      return [AppStringValues.opened, Colors.green, true];
    } else {
      return [AppStringValues.closed, Colors.red, true];
    }
  }
}
