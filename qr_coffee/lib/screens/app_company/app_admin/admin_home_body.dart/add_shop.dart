import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class AddShop extends StatefulWidget {
  const AddShop({Key? key, required this.company}) : super(key: key);

  final Company company;

  @override
  _AddShopState createState() => _AddShopState();
}

class _AddShopState extends State<AddShop> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();
  bool loading = false;
  String errorMessage = '';
  late Company company;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = Responsive.deviceWidth(context);
    company = widget.company;

    return Scaffold(
      appBar: customAppBar(context, title: Text(AppStringValues.addNewShop)),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: deviceWidth > kDeviceUpperWidthTreshold ? 400 : Responsive.width(80, context),
            child: Form(
              key: _key,
              child: Column(
                children: [
                  SizedBox(height: Responsive.height(3, context)),
                  _addressForm(),
                  SizedBox(height: Responsive.height(2, context)),
                  Text(
                      '${AppStringValues.openingHours} (${AppStringValues.from}/${AppStringValues.to})',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: Responsive.height(1, context)),
                  _openingHoursTile(),
                  SizedBox(height: Responsive.height(1, context)),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  CustomOutlinedIconButton(
                    function: _addShopFunc,
                    icon: CommunityMaterialIcons.store,
                    label: AppStringValues.addShop,
                    iconColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _formCallback(varLabel, varValue) {
    formField[varLabel] = varValue;
  }

  _addShopFunc() async {
    setState(() {
      loading = true;
      errorMessage = '';
    });

    FocusManager.instance.primaryFocus!.unfocus();

    if (_key.currentState!.validate()) {
      _key.currentState!.save();

      if (_hoursAreFilled()) {
        String address = (formField[AppStringValues.address] ?? '').trim();
        String city = (formField[AppStringValues.city] ?? '').trim();
        String openingHours = '${formField['1']}-${formField['2']}';

        try {
          ShopDatabase(companyId: company.uid).addShop(address, city, openingHours, company.name);
          CompanyDatabase(uid: company.uid).updateCompanyShopNum(company.numShops + 1);
          Navigator.pop(context);
          customSnackbar(context: context, text: AppStringValues.shopCreationSuccess);
        } catch (e) {
          customSnackbar(context: context, text: e.toString());
        }
      } else {
        setState(() => loading = false);
        errorMessage = AppStringValues.enterOpeningHours;
      }
    } else {
      setState(() => loading = false);
    }
  }

  _hoursAreFilled() {
    if (formField['1'] != null && formField['2'] != null) {
      return true;
    } else {
      return false;
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
        ),
        CustomTextField(
          AppStringValues.city,
          Icons.location_city,
          _formCallback,
          validation: validateCity,
        ),
      ],
    );
  }

  Widget _openingHoursTile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomTimeDropdown(values: kHours, callback: _formCallback, label: '1'),
        SizedBox(width: Responsive.width(1, context)),
        CustomTimeDropdown(values: kHours, callback: _formCallback, label: '2'),
      ],
    );
  }
}
