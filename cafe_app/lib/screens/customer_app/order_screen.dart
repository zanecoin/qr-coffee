import 'package:cafe_app/models/coffee.dart';
import 'package:cafe_app/models/place.dart';
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/screens/sidebar/credit_card_screen.dart';
import 'package:cafe_app/service/database.dart';
import 'package:cafe_app/shared/constants.dart';
import 'package:cafe_app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Object? _currentCoffee;
  Object? _currentPlace;
  List<dynamic> _selectedItems = [];
  bool loading = false;
  double plusTime = 5;

  String _batteryLevel = 'Unknown battery level.';
  static const platform = MethodChannel('com.example.cafe_app/payment');

  @override
  Widget build(BuildContext context) {
    // get currently logged user and theme provider
    final user = Provider.of<User?>(context);
    return StreamBuilder3<List<Coffee>, List<Place>, UserData>(
      streams: Tuple3(DatabaseService().coffeeList, DatabaseService().placeList,
          DatabaseService(uid: user!.uid).userData),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData &&
            snapshots.item2.hasData &&
            snapshots.item3.hasData) {
          List<Coffee> coffees = snapshots.item1.data!;
          List<Place> places = snapshots.item2.data!;
          UserData userData = snapshots.item3.data!;

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
                    color: Colors.black, fontSize: 30, fontFamily: 'Galada'),
              ),
              centerTitle: true,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
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
                              style:
                                  TextStyle(fontSize: 17, color: Colors.black),
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
                              text('Vaše objednávka', 16, FontWeight.normal),
                              dynamicChips(),
                              text('${_totalPrice(coffees)} Kč', 30,
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
                          onChanged: (val) => setState(() => plusTime = val),
                          min: 5,
                          max: 30,
                          divisions: 25,
                          //label: ,
                          activeColor: Colors.black,
                        ),
                        Center(
                          child: Text(
                            'Za ${plusTime.toInt()} min',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Center(
                          child: Text(
                            '(${_getEnhancedTime().substring(8, 10)}:${_getEnhancedTime().substring(10, 12)})',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        divider(),
                        userData.card == 0
                            ? text('Nemáte přidanou platební kartu', 16,
                                FontWeight.normal, color: Colors.red.shade700)
                            : text('Platba uloženou kartou', 16,
                                FontWeight.normal),
                        SizedBox(height: Responsive.height(2, context)),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: Responsive.width(12, context)),
                          child: ElevatedButton(
                            child: loading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    userData.card == 0
                                        ? 'Přidat platební kartu'
                                        : 'Objednat kávu nyní!',
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white),
                                  ),
                            onPressed: () {
                              _getBatteryLevel();

                              if (userData.card == 0) {
                                Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                    builder: (context) => CardScreen(),
                                  ),
                                );
                              } else {
                                _placeOrderEvent(coffees, userData);
                              }
                            },
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
                        SizedBox(height: Responsive.height(3, context)),
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
  }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
    print(_batteryLevel);
  }

  String _getEnhancedTime() {
    String time = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    String newTime =
        (int.parse(time.substring(10, 12)) + plusTime.toInt()).toString();
    if (int.parse(newTime) >= 60) {
      newTime = (int.parse(time.substring(9, 12)) + plusTime.toInt() + 100 - 60)
          .toString();
      newTime = '${time.substring(0, 9)}$newTime${time.substring(12, 14)}';
    } else {
      newTime = '${time.substring(0, 10)}$newTime${time.substring(12, 14)}';
    }
    return newTime;
  }

  int _totalPrice(List<Coffee> coffees) {
    int result = 0;
    for (var item in _selectedItems) {
      for (var coffee in coffees) {
        if (coffee.name == item.name) result += coffee.price;
      }
    }
    return result;
  }

  List<String> _createCoffeeList() {
    List<String> result = [];
    for (var item in _selectedItems) {
      result.add(item.name);
    }
    result.sort();
    return result;
  }

  void _placeOrderEvent(List<Coffee> coffees, UserData userData) async {
    setState(() {
      loading = true;
      //errorMessage = '';
    });
    if (_selectedItems.isNotEmpty && _currentPlace != null) {
      // calculate time added by user
      String newTime = _getEnhancedTime();

      // place an active order to database
      DocumentReference _docRef = await DatabaseService().createOrder(
        'active',
        _createCoffeeList(),
        _totalPrice(coffees),
        newTime,
        '${userData.name} ${userData.surname}',
        userData.spz,
        _currentPlace.toString(),
        '', // first give en empty order ID
        userData.uid,
      );

      await DatabaseService().setOrderId(
        'active',
        _createCoffeeList(),
        _totalPrice(coffees),
        newTime,
        '${userData.name} ${userData.surname}',
        userData.spz,
        _currentPlace.toString(),
        _docRef.id,
        userData.uid,
      );

      for (Coffee item in _selectedItems) {
        print(item.name);
        await DatabaseService().updateCoffeeData(
          item.uid,
          item.name,
          item.price,
          item.count + 1,
        );
      }

      Navigator.pop(context);
    } else {
      String message;

      if (_selectedItems.isEmpty && _currentPlace != null) {
        message = 'Vyberte druh kávy.';
      } else if (_selectedItems.isNotEmpty && _currentPlace == null) {
        message = 'Vyberte odběrové místo.';
      } else {
        message = 'Vyberte odběrové místo a druh kávy.';
      }

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(milliseconds: 2000),
        ),
      );
    }
  }

  Widget text(String string, double size, FontWeight fontWeight,
      {Color color = Colors.black}) {
    return Text(
      string,
      style: TextStyle(
        color: color,
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

  Widget dynamicChips() {
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
