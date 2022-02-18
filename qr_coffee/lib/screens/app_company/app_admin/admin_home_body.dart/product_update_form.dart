import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class ProductUpdateForm extends StatefulWidget {
  ProductUpdateForm({Key? key, required this.product}) : super(key: key);
  final Product product;

  @override
  _ProductUpdateFormState createState() => _ProductUpdateFormState(product: product);
}

class _ProductUpdateFormState extends State<ProductUpdateForm> {
  _ProductUpdateFormState({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, title: Text(AppStringValues.productDetail)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _fancyInfoCard(product),
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

Widget _fancyInfoCard(Product coffee) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    child: Card(
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
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
                      image: AssetImage('assets/cafe.jpg'),
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
                  style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${coffee.price} ${AppStringValues.currency}',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
