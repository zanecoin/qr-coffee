import 'package:qr_coffee/models/coffee.dart';
import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:qr_coffee/shared/image_banner.dart';
import 'package:flutter/material.dart';

class CoffeeKindTile extends StatelessWidget {
  final Coffee coffee;
  final Function callback;

  CoffeeKindTile({required this.coffee, required this.callback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: InkWell(
          onTap: () => callback(coffee),
          child: Stack(
            children: [
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(30),
              //   child: ImageBanner(path: 'assets/cafe3.jpg', size: 'small'),
              // ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    coffee.type == 'drink'
                        ? ImageBanner(path: 'assets/cafe3.jpg', size: 'medium')
                        : ImageBanner(
                            path: 'assets/croissant.jpg', size: 'medium'),
                    Text(
                      '${coffee.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${coffee.price} Kč',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoffeeKindScreen extends StatefulWidget {
  // GET USER DATA FORM PREVIOUS HOMESCREEN TO GET INIT VALUE FOR CARD SELECTION
  final Coffee coffee;
  CoffeeKindScreen({Key? key, required this.coffee}) : super(key: key);

  @override
  _CoffeeKindScreenState createState() =>
      _CoffeeKindScreenState(coffee: coffee);
}

class _CoffeeKindScreenState extends State<CoffeeKindScreen> {
  final Coffee coffee;
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

Widget _fancyInfoCard(Coffee coffee) {
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
