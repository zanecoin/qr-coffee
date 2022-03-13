import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/shop_update_form.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class AdminShopDetails extends StatefulWidget {
  const AdminShopDetails({Key? key, required this.shop}) : super(key: key);

  final Shop shop;

  @override
  _AdminShopDetailsState createState() => _AdminShopDetailsState();
}

class _AdminShopDetailsState extends State<AdminShopDetails> {
  late Shop shop;
  late Company company;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = Responsive.deviceWidth(context);
    company = Provider.of<Company>(context);

    if (company.companyID != '') {
      return StreamBuilder<Shop>(
        stream: ShopDatabase(companyID: company.companyID, shopID: widget.shop.shopID).shop,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            shop = snapshot.data!;

            return Scaffold(
              appBar: customAppBar(context, title: Text(AppStringValues.shopDetails)),
              body: SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: deviceWidth > kDeviceUpperWidthTreshold
                        ? 400
                        : Responsive.width(80, context),
                    child: Column(
                      children: [
                        SizedBox(height: Responsive.height(3, context)),
                        CustomCircleAvatar(icon: Icons.store),
                        SizedBox(height: Responsive.height(3, context)),
                        Text(
                          cutTextIfNeccessary(shop.address, Responsive.textTresholdShort(context)),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                        ),
                        Text('${shop.city}', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: Responsive.height(2, context)),
                        Text(AppStringValues.openingHours, style: TextStyle(fontSize: 16)),
                        SizedBox(height: Responsive.height(1, context)),
                        CustomTextBanner(title: shop.openingHours, showIcon: false),
                        SizedBox(height: Responsive.height(10, context)),
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
}
