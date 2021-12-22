import 'package:qr_coffee/models/item.dart';
import 'package:qr_coffee/models/place.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/coffee_inventory.dart';
import 'package:qr_coffee/screens/order_screens/create_order/func_place_order.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/widgets/custom_button_style.dart';
import 'package:qr_coffee/shared/widgets/custom_divider.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/widgets/custom_dropdown.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';

class CreateOrder extends StatefulWidget {
  final List<Map<String, dynamic>> databaseImages;

  const CreateOrder({Key? key, required this.databaseImages}) : super(key: key);

  @override
  _CreateOrderState createState() =>
      _CreateOrderState(databaseImages: databaseImages);
}

class _CreateOrderState extends State<CreateOrder>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> databaseImages;

  _CreateOrderState({required this.databaseImages});

  String? _currentPlace;
  bool loading = false;
  double plusTime = 5;
  List<String> choices = [CzechStrings.drink, CzechStrings.food];
  List<dynamic> _selectedItems = [];
  late TabController controller;
  int screenNum = 1;
  int paymentMethod = 2;
  String role = '';

  // UPPER TAB CONTROLLER
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

  // BACK BUTTON BEHAVIOR
  Future<bool> _onWillPop() async {
    if (screenNum == 1) {
      return true;
    } else {
      switchScreenNum();
      return false;
    }
  }

  // ICON CHOOSER FOR SUBMIT BUTTON
  Icon _buttonIcon() {
    IconData icon = Icons.check_circle;

    if (screenNum == 1) {
      if (role == 'customer' || role == 'worker-off') {
        icon = CommunityMaterialIcons.arrow_right_circle;
      } else if (role == 'worker-on') {
        icon = CommunityMaterialIcons.upload_outline;
      }
    }

    return Icon(icon, color: Colors.green);
  }

  // TEXT CHOOSER FOR SUBMIT BUTTON
  Text _buttonText() {
    String text = CzechStrings.orderNow;

    if (screenNum == 1) {
      if (role == 'customer' || role == 'worker-off') {
        text = CzechStrings.continueOn;
      } else if (role == 'worker-on') {
        text = CzechStrings.createOrder;
      }
    }

    return Text(text, style: TextStyle(fontSize: 17, color: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    // GET CURRENTLY LOGGED USER AND DATA STREAMS
    final user = Provider.of<User?>(context);
    return StreamBuilder3<List<Item>, List<Place>, UserData>(
      streams: Tuple3(
        DatabaseService().coffeeList,
        DatabaseService().placeList,
        DatabaseService(uid: user!.uid).userData,
      ),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData &&
            snapshots.item2.hasData &&
            snapshots.item3.hasData) {
          List<Item> items = snapshots.item1.data!;
          List<Place> places = snapshots.item2.data!;
          UserData userData = snapshots.item3.data!;
          role = userData.role;
          _currentPlace = userData.stand;

          return WillPopScope(
            onWillPop: () async => _onWillPop(),
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
                          ? _orderContent(items, databaseImages)
                          : _orderDelivery(places)),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
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
                              '${getTotalPrice(items, _selectedItems)} ${CzechStrings.currency}',
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
                            icon: _buttonIcon(),
                            label: _buttonText(),
                            onPressed: () {
                              if (screenNum == 1) {
                                if (role == 'customer' ||
                                    role == 'worker-off') {
                                  setState(() {
                                    screenNum = 2;
                                  });
                                } else if (role == 'worker-on') {
                                  setState(() => loading = true);
                                  createOrder(
                                    context,
                                    items,
                                    userData,
                                    _selectedItems,
                                    _currentPlace,
                                    paymentMethod,
                                    role,
                                    plusTime,
                                  );
                                  setState(() => loading = false);
                                }
                              } else {
                                if (role == 'customer' ||
                                    role == 'worker-off') {
                                  setState(() => loading = true);
                                  createOrder(
                                    context,
                                    items,
                                    userData,
                                    _selectedItems,
                                    _currentPlace,
                                    paymentMethod,
                                    role,
                                    plusTime,
                                  );
                                  setState(() => loading = false);
                                }
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

  void callbackDropdown(value) {
    _currentPlace = value;
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

  Widget _orderContent(List<Item> items, databaseImages) {
    return TabBarView(
      controller: controller,
      children: choices
          .map((choice) => _orderGrid(items, choice, databaseImages))
          .toList(),
    );
  }

  Widget _orderGrid(items, choice, databaseImages) {
    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      children: _filter(items, choice)
          .map((item) => CoffeeKindTile(
                item: item,
                callback: appendItem,
                imageUrl: chooseUrl(databaseImages, item.picture),
              ))
          .toList(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
    );
  }

  Widget _orderGrid2(items, choice, databaseImages) {
    items = _filter(items, choice);
    return GridView.builder(
        itemCount: items.length,
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int index) {
          return CoffeeKindTile(
            item: items[index],
            callback: appendItem,
            imageUrl: chooseUrl(databaseImages, items[index].picture),
          );
        });
  }

  Widget _orderDelivery(List<Place> places) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: Responsive.height(2, context)),
          _text(CzechStrings.orderPlace, 16, FontWeight.normal),
          CustomPlaceDropdown(places, true, callbackDropdown, _currentPlace),
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
          SizedBox(height: Responsive.height(2, context)),
          CustomDivider(),
          SizedBox(height: Responsive.height(2, context)),
          _text(CzechStrings.paymentMethod, 16, FontWeight.normal),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    paymentMethod = 1;
                  });
                },
                child: Text(CzechStrings.withCard),
                style: TextButton.styleFrom(
                  backgroundColor:
                      paymentMethod == 1 ? Colors.black : Colors.white,
                  primary: paymentMethod == 1 ? Colors.white : Colors.grey,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    paymentMethod = 2;
                  });
                },
                child: Text(CzechStrings.withTokens),
                style: TextButton.styleFrom(
                  backgroundColor:
                      paymentMethod == 2 ? Colors.black : Colors.white,
                  primary: paymentMethod == 2 ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.height(2, context)),
        ],
      ),
    );
  }
}
