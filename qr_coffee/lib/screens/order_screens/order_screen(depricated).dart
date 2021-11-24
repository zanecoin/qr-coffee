import 'package:qr_coffee/models/coffee.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/place.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:qr_coffee/shared/custom_buttons.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/loading.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    // GET CURRENTLY LOGGED USER AND DATA STREAMS
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
            appBar: customAppBar(context, elevation: 0),
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
                        text(CzechStrings.orderItems, 16, FontWeight.normal),
                        coffeeSelect(coffees),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: Responsive.width(12, context)),
                          child: ElevatedButton(
                            child: Text(
                              CzechStrings.addToOrder,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                              ),
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
                            style: customButtonStyle(
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.height(2, context)),
                        if (_selectedItems.length != 0)
                          Column(
                            children: [
                              text(
                                CzechStrings.yourOrder,
                                16,
                                FontWeight.normal,
                              ),
                              dynamicChips(),
                              text(
                                '${getTotalPrice(coffees, _selectedItems)} Kč',
                                30,
                                FontWeight.bold,
                              ),
                            ],
                          ),
                        divider(),
                        text(CzechStrings.orderPlace, 16, FontWeight.normal),
                        placeSelect(places),
                        text(CzechStrings.orderTime, 16, FontWeight.normal),
                        Slider.adaptive(
                          value: plusTime,
                          onChanged: (val) => setState(() => plusTime = val),
                          min: 5,
                          max: 30,
                          divisions: 25,
                          activeColor: Colors.black,
                        ),
                        Center(
                          child: Text(
                            'Za ${plusTime.toInt()} min',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            //'${getPickUpTime(plusTime)}',
                            '(${getPickUpTime(plusTime).substring(8, 10)}:${getPickUpTime(plusTime).substring(10, 12)})',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        SizedBox(height: Responsive.height(2, context)),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: Responsive.width(12, context)),
                          child: ElevatedButton.icon(
                            icon: loading
                                ? Icon(null)
                                : Icon(Icons.check_circle, color: Colors.green),
                            label: loading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    CzechStrings.orderNow,
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                            onPressed: () {
                              _placeOrderEvent(coffees, userData);
                            },
                            style: customButtonStyle(),
                          ),
                        ),
                        SizedBox(height: Responsive.height(3, context)),
                        //_buildBody(context)
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

  void _placeOrderEvent(List<Coffee> coffees, UserData userData) async {
    setState(() {
      loading = true;
      //errorMessage = '';
    });
    if (_selectedItems.isNotEmpty && _currentPlace != null) {
      // create order params
      String state = 'active';
      List<String> items = getStringList(_selectedItems);
      int price = getTotalPrice(coffees, _selectedItems);
      String pickUpTime = getPickUpTime(plusTime);
      String username = '${userData.name} ${userData.surname}';
      String spz = userData.spz;
      String place = _currentPlace.toString();
      String orderId = '';
      String userId = userData.uid;

      // place an active order to database
      DocumentReference _docRef = await DatabaseService().createOrder(state,
          items, price, pickUpTime, username, spz, place, orderId, userId);

      // get and add order ID
      await DatabaseService().setOrderId(state, items, price, pickUpTime,
          username, spz, place, _docRef.id, userId);

      // update quantity of particular coffee type
      for (Coffee item in _selectedItems) {
        await DatabaseService().updateCoffeeData(
          item.uid,
          item.name,
          item.type,
          item.price,
          item.count + 1,
        );
      }

      // create order instance for webview
      Order order = Order(
        state: state,
        coffee: items,
        price: price,
        pickUpTime: pickUpTime,
        username: username,
        spz: spz,
        place: place,
        orderId: _docRef.id,
        userId: userId,
      );

      // launch webview
      //launchPaymentGateway(context, _totalOrderPrice(coffees), coffees, order);
    } else {
      // notify user something is wrong with order parameters
      String message;

      if (_selectedItems.isEmpty && _currentPlace != null) {
        message = CzechStrings.chooseItemsDot;
      } else if (_selectedItems.isNotEmpty && _currentPlace == null) {
        message = CzechStrings.choosePlaceDot;
      } else {
        message = CzechStrings.chooseBothDot;
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
                hint: Text(CzechStrings.chooseItems),
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
                hint: Text(CzechStrings.choosePlace),
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
