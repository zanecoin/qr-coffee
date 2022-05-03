import 'package:provider/provider.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class ProductTile extends StatefulWidget {
  ProductTile({
    required this.item,
    required this.onItemTap,
    required this.onItemLongPress,
    required this.imageUrl,
    required this.companyID,
    required this.shopID,
  });

  final Product item;
  final Function? onItemTap;
  final Function? onItemLongPress;
  final String imageUrl;
  final String companyID;
  final String shopID;

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  Image image() {
    if (widget.imageUrl == '') {
      return Image.asset('assets/blank.png');
    } else {
      //return Image.network(imageUrl);
      // return Image(
      //     image: CachedNetworkImageProvider(
      //   imageUrl,
      // ));

      return Image.network(
        widget.imageUrl,
        fit: BoxFit.fill,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Colors.red,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    double normalOpacity = themeProvider.isLightMode() ? 1.0 : 0.8;
    double souldoutOpacity = themeProvider.isLightMode() ? 0.6 : 0.3;

    return StreamBuilder<Shop>(
      stream: ShopDatabase(companyID: widget.companyID, shopID: widget.shopID).shop,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<dynamic> soldoutProducts = snapshot.data!.soldoutProducts;
          print(soldoutProducts);
          bool soldout = soldoutProducts.contains(widget.item.productID);
          String text = soldout ? AppStringValues.soldout : '';
          ColorFilter filter = soldout
              ? ColorFilter.mode(Colors.grey.withOpacity(souldoutOpacity), BlendMode.dstATop)
              : ColorFilter.mode(Colors.black.withOpacity(normalOpacity), BlendMode.dstATop);
          return Container(
            margin: EdgeInsets.all(7.0),
            height: 200.0,
            width: 150.0,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              color: themeProvider.themeData().backgroundColor,
              image: DecorationImage(
                colorFilter: filter,
                image: image().image,
                fit: BoxFit.cover,
              ),
              boxShadow: themeProvider.themeAdditionalData().shadow,
            ),
            child: InkWell(
              onTap: widget.onItemTap == null ? null : () => widget.onItemTap!(widget.item),
              onLongPress: widget.onItemLongPress == null
                  ? null
                  : () => widget.onItemLongPress!(widget.item),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  (!Responsive.isSmallDevice(context) && !Responsive.isLargeDevice(context))
                      ? _textContainerA(context, themeProvider)
                      : _textContainerB(context, themeProvider),
                  Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }

  Widget _textContainerA(BuildContext context, ThemeProvider themeProvider) {
    return Positioned(
      bottom: 12.0,
      child: Container(
        width: Responsive.width(37.0, context),
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: themeProvider.themeData().backgroundColor,
        ),
        child: _text(themeProvider),
      ),
    );
  }

  Widget _textContainerB(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      width: Responsive.width(100, context),
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(
            width: 1.5, color: themeProvider.isLightMode() ? Colors.white : Colors.grey.shade800)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        color: themeProvider.themeAdditionalData().containerColor,
      ),
      child: _text(themeProvider),
    );
  }

  RichText _text(ThemeProvider themeProvider) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: '${widget.item.name}\n',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: themeProvider.themeAdditionalData().textColor,
            fontSize: 10.0,
          ),
        ),
        TextSpan(
          text: '${widget.item.price} ${AppStringValues.currency}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.themeAdditionalData().textColor,
            fontSize: 14.0,
          ),
        ),
      ]),
      textAlign: TextAlign.center,
    );
  }
}
