import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductTile extends StatelessWidget {
  ProductTile({
    required this.item,
    required this.onItemTap,
    required this.imageUrl,
    required this.largeDevice,
  });

  final Product item;
  final Function onItemTap;
  final String imageUrl;
  final bool largeDevice;

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
    final double deviceWidth = Responsive.deviceWidth(context);

    return Container(
      margin: EdgeInsets.all(15),
      height: 200,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
        color: Colors.white,
        image: DecorationImage(
          colorFilter: new ColorFilter.mode(
            Colors.black.withOpacity(1),
            BlendMode.dstATop,
          ),
          image: image().image,
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade600,
            offset: Offset(1, 1),
            blurRadius: 10,
            spreadRadius: 0,
          )
        ],
      ),
      child: InkWell(
        onTap: () => onItemTap(item),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            (deviceWidth > kDeviceLowerWidthTreshold && !largeDevice)
                ? _textContainerA(context)
                : _textContainerB(context),
          ],
        ),
      ),
    );
  }

  Widget _textContainerA(BuildContext context) {
    return Positioned(
      bottom: 15,
      child: Container(
        width: Responsive.width(35, context),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: Text(
          '${item.name}\n${item.price} Kč',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.black,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _textContainerB(BuildContext context) {
    return Container(
      width: Responsive.width(100, context),
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        color: Colors.white,
      ),
      child: Text(
        '${item.name}\n${item.price} Kč',
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.black,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
