import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CoffeeKindTile extends StatelessWidget {
  CoffeeKindTile({
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
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Colors.red,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
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

class CoffeeKindScreen extends StatefulWidget {
  // GET USER DATA FORM PREVIOUS HOMESCREEN TO GET INIT VALUE FOR CARD SELECTION
  final Product coffee;
  CoffeeKindScreen({Key? key, required this.coffee}) : super(key: key);

  @override
  _CoffeeKindScreenState createState() =>
      _CoffeeKindScreenState(coffee: coffee);
}

class _CoffeeKindScreenState extends State<CoffeeKindScreen> {
  final Product coffee;
  _CoffeeKindScreenState({required this.coffee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, title: Text('')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _fancyInfoCard(coffee),
            Text(
              '16g kávy',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            Text(
              '60ml vody',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
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
                      colorFilter: new ColorFilter.mode(
                          Colors.black.withOpacity(0.2), BlendMode.dstATop),
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
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  '${coffee.price} Kč',
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

// OLDER STYLE -------------------------------------------------------------------

// class CoffeeKindTile extends StatelessWidget {
//   final Item coffee;
//   final Function callback;

//   CoffeeKindTile({required this.coffee, required this.callback});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
//       child: Card(
//         elevation: 5,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: InkWell(
//           onTap: () => callback(coffee),
//           child: Stack(
//             children: [
//               // ClipRRect(
//               //   borderRadius: BorderRadius.circular(30),
//               //   child: ImageBanner(path: 'assets/cafe3.jpg', size: 'small'),
//               // ),
//               Center(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     coffee.type == 'drink'
//                         ? ImageBanner(path: 'assets/cafe3.jpg', size: 'medium')
//                         : ImageBanner(
//                             path: 'assets/croissant.jpg', size: 'medium'),
//                     Text(
//                       '${coffee.name}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                         fontSize: 14,
//                       ),
//                     ),
//                     Text(
//                       '${coffee.price} Kč',
//                       style: TextStyle(color: Colors.black, fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }