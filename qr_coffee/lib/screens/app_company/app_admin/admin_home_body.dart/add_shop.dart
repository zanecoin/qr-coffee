import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/custom_button.dart';
import 'package:qr_coffee/shared/widgets/custom_time_dropdown.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class AddShop extends StatefulWidget {
  const AddShop({Key? key}) : super(key: key);

  @override
  _AddShopState createState() => _AddShopState();
}

class _AddShopState extends State<AddShop> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  Map<String, String> formField = Map<String, String>();
  bool loading = false;
  String errorMessage = '';

  String address = '';
  String city = '';
  String openingHours = '';

  @override
  Widget build(BuildContext context) {
    double deviceWidth = Responsive.deviceWidth(context);

    return Scaffold(
      appBar: customAppBar(context, title: Text(CzechStrings.addNewShop)),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: deviceWidth > kDeviceUpperWidthTreshold ? 400 : Responsive.width(80, context),
            child: Form(
              key: _key,
              child: Column(
                children: [
                  SizedBox(height: Responsive.height(3, context)),
                  CustomTextField(
                    CzechStrings.address,
                    Icons.gps_fixed,
                    callback,
                    validation: validateAddress,
                  ),
                  CustomTextField(
                    CzechStrings.city,
                    Icons.location_city,
                    callback,
                    validation: validateCity,
                  ),
                  SizedBox(height: Responsive.height(2, context)),
                  Text(CzechStrings.openingHours, style: TextStyle(fontSize: 16)),
                  SizedBox(height: Responsive.height(1, context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(CzechStrings.from, style: TextStyle(fontSize: 16)),
                      SizedBox(width: Responsive.width(3, context)),
                      CustomTimeDropdown(values: kHours, callback: callback, label: '1'),
                      SizedBox(width: Responsive.width(5, context)),
                      CustomTimeDropdown(values: kMinutes, callback: callback, label: '2'),
                      SizedBox(width: Responsive.width(3, context)),
                      Text('    ', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: Responsive.height(2, context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(CzechStrings.to, style: TextStyle(fontSize: 16)),
                      SizedBox(width: Responsive.width(3, context)),
                      CustomTimeDropdown(values: kHours, callback: callback, label: '3'),
                      SizedBox(width: Responsive.width(5, context)),
                      CustomTimeDropdown(values: kMinutes, callback: callback, label: '4'),
                      SizedBox(width: Responsive.width(3, context)),
                      Text('    ', style: TextStyle(fontSize: 16)),
                    ],
                  ),
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
                    function: addShop,
                    icon: CommunityMaterialIcons.upload_outline,
                    label: CzechStrings.addShop,
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

  // TextFormField callback function.
  callback(varLabel, varValue) {
    formField[varLabel] = varValue;
  }

  addShop() async {
    setState(() {
      loading = true;
      errorMessage = '';
    });

    FocusManager.instance.primaryFocus!.unfocus();

    if (_key.currentState!.validate()) {
      _key.currentState!.save();

      if (_hoursFilled(formField)) {
        address = (formField[CzechStrings.address] ?? '').trim();
        city = (formField[CzechStrings.city] ?? '').trim();
        openingHours = '${formField['1']}:${formField['2']}-${formField['3']}:${formField['4']}';

        ShopDatabase().addShop(address, city, openingHours);
        Navigator.pop(context);
      } else {
        setState(() => loading = false);
        errorMessage = CzechStrings.enterOpeningHours;
      }
    } else {
      setState(() => loading = false);
    }
  }
}

_hoursFilled(Map<String, String> formField) {
  if (formField['1'] != null &&
      formField['2'] != null &&
      formField['3'] != null &&
      formField['4'] != null) {
    return true;
  } else {
    return false;
  }
}
