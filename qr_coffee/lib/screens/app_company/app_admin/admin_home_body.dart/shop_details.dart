import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/shop_update_form.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class AdminShopDetails extends StatefulWidget {
  const AdminShopDetails({Key? key, required this.shop}) : super(key: key);

  final Shop shop;

  @override
  _AdminShopDetailsState createState() => _AdminShopDetailsState();
}

class _AdminShopDetailsState extends State<AdminShopDetails> {
  late Shop shop;
  late Company company;
  late List<Product> products;

  @override
  Widget build(BuildContext context) {
    company = Provider.of<Company>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (company.companyID != '') {
      return StreamBuilder2<Shop, List<Product>>(
        streams: Tuple2(
          ShopDatabase(companyID: company.companyID, shopID: widget.shop.shopID).shop,
          ProductDatabase(companyID: company.companyID).products,
        ),
        builder: (context, snapshots) {
          if (snapshots.item1.hasData && snapshots.item2.hasData) {
            shop = snapshots.item1.data!;
            products = snapshots.item2.data!;

            return Scaffold(
              backgroundColor: themeProvider.themeData().backgroundColor,
              appBar: customAppBar(context,
                  title: Text(
                    AppStringValues.shopDetails,
                    style: TextStyle(
                      color: themeProvider.themeAdditionalData().textColor,
                      fontSize: 16.0,
                    ),
                  )),
              body: SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: Responsive.isLargeDevice(context) ? 400 : Responsive.width(80, context),
                    child: Column(
                      children: [
                        SizedBox(height: Responsive.height(3, context)),
                        CustomCircleAvatar(icon: Icons.store),
                        SizedBox(height: Responsive.height(3, context)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.place,
                              color: themeProvider.themeAdditionalData().textColor,
                            ),
                            Text(
                              cutTextIfNeccessary(
                                  shop.address, Responsive.textTresholdShort(context)),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                                color: themeProvider.themeAdditionalData().textColor,
                              ),
                            ),
                          ],
                        ),
                        Text('${shop.city}',
                            style: TextStyle(
                              color: themeProvider.themeAdditionalData().unselectedColor,
                            )),
                        SizedBox(height: Responsive.height(2, context)),
                        CustomDividerWithText(text: AppStringValues.openingHours),
                        CustomTextBanner(title: shop.openingHours, showIcon: false),
                        SizedBox(height: Responsive.height(2, context)),
                        CustomDividerWithText(text: AppStringValues.soldoutProducts),
                        _productList(),
                        SizedBox(height: Responsive.height(2, context)),
                        CustomDividerWithText(text: AppStringValues.actions),
                        CustomOutlinedIconButton(
                          function: _openEditing,
                          icon: CommunityMaterialIcons.file_edit_outline,
                          label: AppStringValues.editInfo,
                          iconColor: Colors.blue,
                        ),
                        SizedBox(height: Responsive.height(1, context)),
                        CustomOutlinedIconButton(
                          function: _showDialog,
                          icon: CommunityMaterialIcons.skull_crossbones,
                          label: AppStringValues.deleteShop,
                          iconColor: Colors.red,
                        ),
                      ],
                    ),
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

  void _openEditing() {
    Navigator.push(context,
        new MaterialPageRoute(builder: (context) => ShopUpdateForm(shop: shop, company: company)));
  }

  _showDialog() {
    customAlertDialog(context, _deleteShop);
  }

  _deleteShop() {
    try {
      ShopDatabase(companyID: company.companyID).deleteShop(shop.shopID);
      CompanyDatabase(companyID: company.companyID).updateCompanyShopNum(company.numShops - 1);
      customSnackbar(context: context, text: AppStringValues.shopDeletionSuccess);
    } catch (e) {
      customSnackbar(context: context, text: e.toString());
    }
  }

  Widget _productList() {
    return SizedBox(
      width: Responsive.isLargeDevice(context) ? Responsive.width(60.0, context) : null,
      child: ListView.builder(
        itemBuilder: (context, index) {
          String title = '';
          for (Product product in products) {
            if (shop.soldoutProducts[index] == product.productID) {
              title = product.name;
            }
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
            child: CustomTextBanner(title: title, showIcon: false),
          );
        },
        itemCount: shop.soldoutProducts.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }
}
