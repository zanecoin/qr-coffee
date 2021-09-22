import 'package:cafe_app/models/coffee.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:flutter/material.dart';

class CoffeeKindTile extends StatelessWidget {
  final Coffee coffee;

  CoffeeKindTile({required this.coffee});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => CoffeeKindScreen(
                  coffee: coffee,
                ),
              ),
            );
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/cafeback1.jpg',
                  fit: BoxFit.fitWidth,
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${coffee.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${coffee.price} Kč',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 22),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(''),
        centerTitle: true,
        elevation: 5,
      ),
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
