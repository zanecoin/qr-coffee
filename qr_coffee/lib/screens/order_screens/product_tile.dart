import 'package:provider/provider.dart';
import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:qr_coffee/shared/theme_provider.dart';

class ProductTile extends StatelessWidget {
  ProductTile({
    required this.item,
    required this.onItemTap,
    required this.imageUrl,
  });

  final Product item;
  final Function onItemTap;
  final String imageUrl;

  Image image() {
    if (imageUrl == '') {
      return Image.asset('assets/blank.png');
    } else {
      //return Image.network(imageUrl);
      // return Image(
      //     image: CachedNetworkImageProvider(
      //   imageUrl,
      // ));
      return Image.network(
        imageUrl,
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

    double opacity = themeProvider.isLightMode() ? 1 : 0.8;

    return Container(
      margin: EdgeInsets.all(7),
      height: 200.0,
      width: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        color: themeProvider.themeData().backgroundColor,
        image: DecorationImage(
          colorFilter: new ColorFilter.mode(
            Colors.black.withOpacity(opacity),
            BlendMode.dstATop,
          ),
          image: image().image,
          fit: BoxFit.cover,
        ),
        boxShadow: themeProvider.themeAdditionalData().shadow,
      ),
      child: InkWell(
        onTap: () => onItemTap(item),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            (!Responsive.isSmallDevice(context) && !Responsive.isLargeDevice(context))
                ? _textContainerA(context, themeProvider)
                : _textContainerB(context, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _textContainerA(BuildContext context, ThemeProvider themeProvider) {
    return Positioned(
      bottom: 12.0,
      child: Container(
        width: Responsive.width(37.0, context),
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(
            width: 1.5, color: themeProvider.isLightMode() ? Colors.white : Colors.grey.shade800)),
        borderRadius: BorderRadius.only(
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
          text: '${item.name}\n',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: themeProvider.themeAdditionalData().textColor,
            fontSize: 10.0,
          ),
        ),
        TextSpan(
          text: '${item.price} ${AppStringValues.currency}',
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
