import 'package:qr_coffee/models/coffee.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/place.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/coffee_inventory.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:qr_coffee/shared/custom_buttons.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/loading.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';

class SetOrderFrame extends StatefulWidget {
  const SetOrderFrame({Key? key}) : super(key: key);

  @override
  _SetOrderFrameState createState() => _SetOrderFrameState();
}

class _SetOrderFrameState extends State<SetOrderFrame>
    with SingleTickerProviderStateMixin {
  Object? _currentPlace;
  bool loading = false;
  double plusTime = 5;
  List<String> choices = [CzechStrings.drink, CzechStrings.food];
  List<dynamic> _selectedItems = [];
  late TabController controller;
  int screenNum = 1;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: choices.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 22),
                onPressed: () {
                  screenNum == 1 ? Navigator.pop(context) : switchScreenNum();
                },
              ),
              title: Text(CzechStrings.orderTitle),
              centerTitle: true,
              elevation: 5,
              bottom: screenNum == 1
                  ? TabBar(
                      controller: controller,
                      labelPadding: EdgeInsets.symmetric(vertical: 0),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey.shade800,
                      indicatorColor: Colors.black,
                      tabs: choices
                          .map<Widget>((choice) => Tab(text: choice))
                          .toList(),
                    )
                  : null,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/cafeteria1.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.45),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                    child: screenNum == 1
                        ? _orderContent(coffees)
                        : _orderDelivery(places)),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    // image: DecorationImage(
                    //   colorFilter: new ColorFilter.mode(
                    //     Colors.black.withOpacity(0),
                    //     BlendMode.dstATop,
                    //   ),
                    //   image: AssetImage('assets/cafeback2.jpg'),
                    //   fit: BoxFit.cover,
                    // ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        offset: Offset(1, 1),
                        blurRadius: 15,
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _text(
                            '${CzechStrings.yourOrder}:    ',
                            16,
                            FontWeight.normal,
                          ),
                          _text(
                            '${getTotalPrice(coffees, _selectedItems)} Kč',
                            22,
                            FontWeight.bold,
                          ),
                        ],
                      ),
                      _dynamicChips(),
                      SizedBox(height: Responsive.height(1, context)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Responsive.width(12, context)),
                        child: ElevatedButton.icon(
                          icon: Icon(
                            screenNum == 1
                                ? CommunityMaterialIcons.arrow_right_circle
                                : Icons.check_circle,
                            color: Colors.green,
                          ),
                          label: Text(
                            screenNum == 1
                                ? CzechStrings.continueOn
                                : CzechStrings.orderNow,
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            if (screenNum == 1) {
                              setState(() {
                                screenNum = 2;
                              });
                            } else {
                              _placeOrderEvent(coffees, userData);
                            }
                          },
                          style: customButtonStyle(),
                        ),
                      ),
                      SizedBox(height: Responsive.height(2, context)),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }

  void appendItem(coffee) {
    setState(() {
      _selectedItems.insert(0, coffee);
    });
  }

  void switchScreenNum() {
    setState(() {
      screenNum = 1;
    });
  }

  List<Coffee> _filter(List<Coffee> coffees, String choice) {
    List<Coffee> result = [];
    for (var item in coffees) {
      if (item.type == 'drink' && choice == CzechStrings.drink) {
        result.add(item);
      }
      if (item.type == 'food' && choice == CzechStrings.food) {
        result.add(item);
      }
    }
    return result;
  }

  Widget _text(String string, double size, FontWeight fontWeight,
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

  Widget _dynamicChips() {
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
              backgroundColor: Colors.grey.shade200,
              onDeleted: () => setState(() => _selectedItems.removeAt(index)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderContent(List<Coffee> coffees) {
    return TabBarView(
      controller: controller,
      children: choices.map((choice) => _orderGrid(coffees, choice)).toList(),
    );
  }

  Widget _orderGrid(coffees, choice) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GridView(
        children: _filter(coffees, choice)
            .map((item) => CoffeeKindTile(coffee: item, callback: appendItem))
            .toList(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 1,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
        ),
      ),
    );
  }

  Widget _orderDelivery(List<Place> places) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _text(CzechStrings.orderPlace, 16, FontWeight.normal),
        _placeSelect(places),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              'assets/map.jpg',
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(height: Responsive.height(1, context)),
        _text(CzechStrings.orderTime, 16, FontWeight.normal),
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
      ],
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
        print(item.name);
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
      Navigator.pop(context);
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

  Widget _placeSelect(List<Place> places) {
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
