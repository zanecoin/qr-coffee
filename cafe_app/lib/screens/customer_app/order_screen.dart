import 'package:cafe_app/models/coffee.dart';
import 'package:cafe_app/models/place.dart';
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/service/database.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:cafe_app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  // get userData from CustomerHome to retrieve user uid to create coffee order
  final UserData userData;
  const OrderScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState(userData: userData);
}

class _OrderScreenState extends State<OrderScreen> {
  _OrderScreenState({required this.userData});
  final UserData? userData;
  Object? _currentCoffee;
  Object? _currentPlace;
  List<dynamic> _selectedItems = [];
  bool loading = false;
  double plusTime = 5;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Coffee>>(
      stream: DatabaseService().coffeeList,
      builder: (context, snapshot1) {
        return StreamBuilder<List<Place>>(
          stream: DatabaseService().placeList,
          builder: (context, snapshot2) {
            if (snapshot1.hasData && snapshot2.hasData) {
              List<Coffee> coffees = snapshot1.data!;
              List<Place> places = snapshot2.data!;

              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios, size: 22),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  title: Text(
                    app_name,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontFamily: 'Galada'),
                  ),
                  centerTitle: true,
                  elevation: 0,
                ),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            text('Co si chcete přidat do objednávky?', 16,
                                FontWeight.normal),
                            coffeeSelect(coffees),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: Responsive.width(12, context)),
                              child: ElevatedButton(
                                child: Text(
                                  'Přidat do objednávky',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black),
                                ),
                                onPressed: () {
                                  for (var coffee in coffees) {
                                    if (coffee.name == _currentCoffee) {
                                      setState(() {
                                        _selectedItems.insert(0, coffee);
                                        _currentCoffee = null;
                                      });
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.grey[200],
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: Responsive.height(2, context)),
                            if (_selectedItems.length != 0)
                              Column(
                                children: [
                                  text(
                                      'Vaše objednávka', 16, FontWeight.normal),
                                  dynamicChips(),
                                  text('${totalPrice(coffees)} Kč', 30,
                                      FontWeight.bold),
                                ],
                              ),
                            divider(),
                            text('Kde si chcete kávu převzít?', 16,
                                FontWeight.normal),
                            placeSelect(places),
                            text('Za jak dlouho?', 16, FontWeight.normal),
                            Slider.adaptive(
                              value: plusTime,
                              onChanged: (val) =>
                                  setState(() => plusTime = val),
                              min: 0,
                              max: 30,
                              divisions: 30,
                              label: '${plusTime.toInt()} min',
                              activeColor: Colors.red.shade400,
                            ),
                            SizedBox(height: Responsive.height(2, context)),
                            // divider(),
                            // text('Kterou kartou chcete platit?', 16,
                            //     FontWeight.normal),
                            // divider(),
                            Container(
                              height: Responsive.height(7, context),
                              margin: EdgeInsets.symmetric(
                                  horizontal: Responsive.width(12, context)),
                              child: ElevatedButton(
                                child: loading
                                    ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        'Objednat kávu nyní!',
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.white),
                                      ),
                                onPressed: () => _placeOrderEvent(coffees),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.black,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: Responsive.height(3, context))
                          ],
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
      },
    );
  }

  int totalPrice(List<Coffee> coffees) {
    int result = 0;
    for (var item in _selectedItems) {
      for (var coffee in coffees) {
        if (coffee.name == item.name) result += coffee.price;
      }
    }
    return result;
  }

  List<String> createCoffeeList() {
    List<String> result = [];
    for (var item in _selectedItems) {
      result.add(item.name);
    }
    result.sort();
    return result;
  }

  _placeOrderEvent(List<Coffee> coffees) async {
    String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    String newTime =
        (int.parse(time.substring(10, 12)) + plusTime.toInt()).toString();

    setState(() {
      loading = true;
      //errorMessage = '';
    });
    if (_selectedItems.length > 0 && _currentPlace != null) {
      // calculate time added by user
      if (int.parse(newTime) >= 60) {
        newTime =
            (int.parse(time.substring(9, 12)) + plusTime.toInt() + 100 - 60)
                .toString();
        newTime = '${time.substring(0, 9)}$newTime${time.substring(10, 12)}';
      } else {
        newTime =
            (int.parse(time.substring(10, 12)) + plusTime.toInt()).toString();
        newTime = '${time.substring(0, 10)}$newTime${time.substring(10, 12)}';
      }

      // place an active order to database
      DocumentReference _docRef = await DatabaseService().createOrder(
        'active',
        createCoffeeList(),
        totalPrice(coffees),
        newTime,
        '${userData!.name} ${userData!.surname}',
        userData!.spz,
        _currentPlace.toString(),
        '', // first give en empty order ID
        userData!.uid,
      );

      await DatabaseService().setOrderId(
        'active',
        createCoffeeList(),
        totalPrice(coffees),
        newTime,
        '${userData!.name} ${userData!.surname}',
        userData!.spz,
        _currentPlace.toString(),
        _docRef.id,
        userData!.uid,
      );

      for (Coffee item in _selectedItems) {
        print(item.name);
        await DatabaseService()
            .updateCoffeeData(item.uid, item.name, item.price, item.count + 1);
      }

      Navigator.pop(context);
    } else {
      setState(() => loading = false);
    }
  }

  Widget text(String string, double size, FontWeight fontWeight) {
    return Text(
      string,
      style: TextStyle(
        color: Colors.black,
        fontSize: size,
        fontWeight: fontWeight,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
      child: Divider(
        color: Colors.grey,
        thickness: 0.5,
        indent: 5,
        endIndent: 5,
      ),
    );
  }

  dynamicChips() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 6,
          runSpacing: 0,
          children: List<Widget>.generate(
            _selectedItems.length,
            (index) => Chip(
              label: Text(_selectedItems[index].name),
              labelPadding: EdgeInsets.fromLTRB(8, 3, 0, 3),
              backgroundColor: Colors.grey[200],
              onDeleted: () => setState(() => _selectedItems.removeAt(index)),
            ),
          ),
        ),
      ),
    );
  }

  Widget coffeeSelect(List<Coffee> coffees) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                hint: Text('Vyberte druh kávy'),
                value: _currentCoffee,
                items: coffees.map((coffee) {
                  return DropdownMenuItem(
                    child: Row(
                      children: [
                        Text(' (${coffee.price} Kč) ${coffee.name}'),
                      ],
                    ),
                    value: coffee.name,
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _currentCoffee = val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget placeSelect(List<Place> places) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                hint: Text('Vyberte odběrové místo'),
                value: _currentPlace,
                items: places.map((place) {
                  return DropdownMenuItem(
                    child: Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: place.active ? Colors.black : Colors.grey,
                        ),
                        Text(
                          ' ${place.address}',
                          style: TextStyle(
                            color: place.active ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    value: place.address,
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _currentPlace = val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
