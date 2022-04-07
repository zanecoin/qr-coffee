import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class ProductDetail extends StatefulWidget {
  ProductDetail({Key? key, required this.product}) : super(key: key);
  final Product product;

  @override
  _ProductDetailState createState() => _ProductDetailState(product: product);
}

class _ProductDetailState extends State<ProductDetail> {
  _ProductDetailState({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.themeData().backgroundColor,
      appBar: customAppBar(context,
          title: Text(
            AppStringValues.productDetail,
            style: TextStyle(
              color: themeProvider.themeAdditionalData().textColor,
              fontSize: 16.0,
            ),
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _fancyInfoCard(product, themeProvider, context),
            SizedBox(height: 30),
            CustomOutlinedIconButton(
              function: _tempFunc,
              icon: CommunityMaterialIcons.file_edit_outline,
              label: AppStringValues.editInfo,
              iconColor: Colors.blue,
            )
          ],
        ),
      ),
    );
  }

  _tempFunc() {
    customSnackbar(context: context, text: 'Funkce "upravit produkt" ještě není implementovaná.*');
  }
}

Widget _fancyInfoCard(Product coffee, ThemeProvider themeProvider, BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    width: Responsive.isLargeDevice(context) ? Responsive.width(50, context) : null,
    decoration: BoxDecoration(
      color: themeProvider.themeAdditionalData().containerColor,
      borderRadius: BorderRadius.all(
        Radius.circular(40),
      ),
      boxShadow: themeProvider.themeAdditionalData().shadow,
    ),
    child: Stack(
      children: [
        Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    colorFilter:
                        new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                    image: AssetImage(
                      themeProvider.isLightMode() ? 'assets/cafe.jpg' : 'assets/cafe_darkmode.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                coffee.name,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.themeAdditionalData().textColor,
                ),
              ),
              Text(
                '${coffee.price} ${AppStringValues.currency}',
                style: TextStyle(
                  fontSize: 30,
                  color: themeProvider.themeAdditionalData().textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
