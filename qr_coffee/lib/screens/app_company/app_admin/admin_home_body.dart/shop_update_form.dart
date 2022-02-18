import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class ShopUpdateForm extends StatefulWidget {
  const ShopUpdateForm({Key? key, required this.shop, required this.company}) : super(key: key);

  final Shop shop;
  final Company company;

  @override
  _ShopUpdateFormState createState() => _ShopUpdateFormState(shop: shop);
}

class _ShopUpdateFormState extends State<ShopUpdateForm> {
  _ShopUpdateFormState({required this.shop});
  final Shop shop;

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();
  bool loading = false;
  String errorMessage = '';
  late Company company;

  @override
  Widget build(BuildContext context) {
    company = widget.company;
    final double deviceWidth = Responsive.deviceWidth(context);

    return Scaffold(
      appBar: customAppBar(context, title: Text(''), type: 1),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            width: deviceWidth > kDeviceUpperWidthTreshold ? Responsive.width(60, context) : null,
            child: Form(
              key: _key,
              child: Column(
                children: <Widget>[
                  _addressForm(),
                  SizedBox(height: 10),
                  CustomOutlinedIconButton(
                    function: _updateShop,
                    icon: CommunityMaterialIcons.file_edit_outline,
                    label: AppStringValues.editInfo,
                    iconColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _formCallback(varLabel, varValue) {
    formField[varLabel] = varValue;
  }

  _updateShop() async {
    setState(() {
      loading = true;
      errorMessage = '';
    });

    FocusManager.instance.primaryFocus!.unfocus();

    if (_key.currentState!.validate()) {
      _key.currentState!.save();

      String address = (formField[AppStringValues.address] ?? shop.address).trim();
      String city = (formField[AppStringValues.city] ?? shop.city).trim();
      String openingHours = '';

      try {
        ShopDatabase(companyId: company.uid).updateShopData(shop.uid, address, shop.coordinates,
            shop.active, city, shop.openingHours, shop.company);
        Navigator.pop(context);
        customSnackbar(context: context, text: AppStringValues.shopInfoChangeSuccess);
      } catch (e) {
        customSnackbar(context: context, text: e.toString());
      }
    } else {
      setState(() => loading = false);
    }
  }

  Widget _addressForm() {
    return Column(
      children: [
        CustomTextField(
          AppStringValues.address,
          Icons.place,
          _formCallback,
          validation: validateAddress,
          initVal: shop.address,
        ),
        CustomTextField(
          AppStringValues.city,
          Icons.location_city,
          _formCallback,
          validation: validateCity,
          initVal: shop.city,
        ),
      ],
    );
  }
}
