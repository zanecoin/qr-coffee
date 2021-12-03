import 'package:qr_coffee/models/item.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/place.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/coffee_inventory.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
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
    return StreamBuilder3<List<Item>, List<Place>, UserData>(
      streams: Tuple3(DatabaseService().coffeeList, DatabaseService().placeList,
          DatabaseService(uid: user!.uid).userData),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData &&
            snapshots.item2.hasData &&
            snapshots.item3.hasData) {
          List<Item> items = snapshots.item1.data!;
          List<Place> places = snapshots.item2.data!;
          UserData userData = snapshots.item3.data!;

          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 22),
                  onPressed: () {
                    screenNum == 1 ? Navigator.pop(context) : switchScreenNum();
                  },
                ),
                title: Text(
                  CzechStrings.orderTitle,
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                centerTitle: true,
                elevation: 0,
                bottom: screenNum == 1
                    ? TabBar(
                        controller: controller,
                        labelPadding: EdgeInsets.symmetric(vertical: 0),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey.shade300,
                        indicatorColor: Colors.black,
                        tabs: choices
                            .map<Widget>((choice) => Tab(text: choice))
                            .toList(),
                      )
                    : null,
              ),
              body: Column(
                children: [
                  Expanded(
                      child: screenNum == 1
                          ? _orderContent(items)
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
                              '${getTotalPrice(items, _selectedItems)} Kč',
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
                                _placeOrderEvent(items, userData);
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

  List<Item> _filter(List<Item> items, String choice) {
    List<Item> result = [];
    for (var item in items) {
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

  Widget _orderContent(List<Item> items) {
    return TabBarView(
      controller: controller,
      children: choices.map((choice) => _orderGrid(items, choice)).toList(),
    );
  }

  Widget _orderGrid(items, choice) {
    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      children: _filter(items, choice)
          .map((item) => CoffeeKindTile(coffee: item, callback: appendItem))
          .toList(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
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

  void _placeOrderEvent(List<Item> items, UserData userData) async {
    setState(() {
      loading = true;
      //errorMessage = '';
    });
    if (_selectedItems.isNotEmpty && _currentPlace != null) {
      // CREATE ORDER PARAMETERS
      String state = 'active';
      List<String> stringList = getStringList(_selectedItems);
      int price = getTotalPrice(items, _selectedItems);
      String pickUpTime = getPickUpTime(plusTime);
      String username = '${userData.name} ${userData.surname}';
      String place = _currentPlace.toString();
      String flag = 'real';
      String orderId = '';
      String userId = userData.uid;

      // PLACE AN ACTIVE ORDER TO DATABASE
      DocumentReference _docRef = await DatabaseService().createOrder(
          state,
          stringList,
          price,
          pickUpTime,
          username,
          place,
          flag,
          orderId,
          userId);

      // GET AN ORDER ID
      await DatabaseService().setOrderId(state, stringList, price, pickUpTime,
          username, place, flag, _docRef.id, userId);

      // UPDATE QUANTITY OF A PARTICULAR ITEM TYPE
      for (Item item in _selectedItems) {
        print(item.name);
        await DatabaseService().updateCoffeeData(
          item.uid,
          item.name,
          item.type,
          item.price,
          item.count + 1,
        );
      }

      // UPDATE USER DATA
      await DatabaseService(uid: userData.uid).updateUserData(
        userData.name,
        userData.surname,
        userData.email,
        userData.role,
        userData.tokens,
        userData.stand,
        userData.numOrders + 1,
      );

      // CREATE ORDER INSTANCE FOR WEBVIEW
      Order order = Order(
        state: state,
        coffee: stringList,
        price: price,
        pickUpTime: pickUpTime,
        username: username,
        place: place,
        flag: 'real',
        orderId: _docRef.id,
        userId: userId,
      );

      // LAUNCH WEBVIEW
      //launchPaymentGateway(context, getTotalPrice(items,_selectedItems), items, order);
      Navigator.pop(context);
    } else {
      // NOTIFY USER SOMETHING IS WRONG WITH ORDER PARAMETERS
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
