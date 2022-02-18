import 'package:qr_coffee/models/product.dart';
import 'package:qr_coffee/models/shop.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/order_screens/create_order/create_order_function.dart';
import 'package:qr_coffee/screens/order_screens/create_order/order_menu.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key, required this.databaseImages, required this.shop})
      : super(key: key);
  final List<Map<String, dynamic>> databaseImages;
  final Shop shop;

  @override
  _CreateOrderScreenState createState() =>
      _CreateOrderScreenState(shop: shop, databaseImages: databaseImages);
}

class _CreateOrderScreenState extends State<CreateOrderScreen> with SingleTickerProviderStateMixin {
  _CreateOrderScreenState({required this.databaseImages, required this.shop});
  final List<Map<String, dynamic>> databaseImages;
  final Shop shop;

  late UserData userData;
  late List<Product> items;
  bool loading = false;
  double plusTime = 5;
  List<String> choices = [AppStringValues.drink, AppStringValues.food];
  List<dynamic> _selectedItems = [];
  late TabController controller;
  int screenNum = 1;
  int paymentMethod = 2;
  String role = '';

  // Upper tab controller.
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

  // Back button behavior.
  Future<bool> _onWillPop() async {
    if (screenNum == 1) {
      return true;
    } else {
      _switchScreenNum();
      return false;
    }
  }

  // Icon chooser for submit button.
  IconData _buttonIcon() {
    IconData icon = Icons.check_circle;

    if (screenNum == 1) {
      if (role == 'customer') {
        icon = CommunityMaterialIcons.arrow_right_circle;
      } else if (role == 'worker') {
        icon = CommunityMaterialIcons.upload_outline;
      }
    }
    return icon;
  }

  // Text chooser for submit button.
  String _buttonText() {
    String text = AppStringValues.orderNow;

    if (screenNum == 1) {
      if (role == 'customer') {
        text = AppStringValues.continueOn;
      } else if (role == 'worker') {
        text = AppStringValues.createOrder;
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final double deviceWidth = Responsive.deviceWidth(context);

    return StreamBuilder3<List<Product>, List<Shop>, UserData>(
      streams: Tuple3(
        ProductDatabase().products,
        ShopDatabase(companyId: 'c9wzSTR2HEnYxmgEC8Wl').shopList,
        UserDatabase(uid: user!.uid).userData,
      ),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData && snapshots.item2.hasData && snapshots.item3.hasData) {
          items = snapshots.item1.data!;
          List<Shop> shops = snapshots.item2.data!;
          userData = snapshots.item3.data!;
          role = userData.role;

          return WillPopScope(
            onWillPop: () async => _onWillPop(),
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 22),
                  onPressed: () {
                    screenNum == 1 ? Navigator.pop(context) : _switchScreenNum();
                  },
                ),
                title: Text(
                  screenNum == 1 ? AppStringValues.orderItems : '',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
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
                        tabs: choices.map<Widget>((choice) => Tab(text: choice)).toList(),
                      )
                    : null,
              ),
              body: Column(
                children: [
                  Expanded(
                      child: screenNum == 1
                          ? OrderMenu(
                              databaseImages: databaseImages,
                              items: items,
                              controller: controller,
                              onItemTap: _appendItem,
                            )
                          : _orderDelivery(shops, deviceWidth, userData)),
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
                        if (loading) Container(height: 140.0, child: Loading(delay: false)),
                        if (!loading)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _text('${AppStringValues.yourOrder}:    ', 16, FontWeight.normal),
                                  _text(
                                    '${getTotalPrice(items, _selectedItems)} ${AppStringValues.currency}',
                                    22,
                                    FontWeight.bold,
                                  ),
                                ],
                              ),
                              _dynamicChips(),
                              SizedBox(height: Responsive.height(1, context)),
                              CustomOutlinedIconButton(
                                function: _buttonFunc,
                                icon: _buttonIcon(),
                                label: _buttonText(),
                                iconColor: Colors.green,
                              ),
                              SizedBox(height: Responsive.height(2, context)),
                            ],
                          ),
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

  void _appendItem(coffee) {
    setState(() {
      _selectedItems.insert(0, coffee);
    });
  }

  void _switchScreenNum() {
    setState(() {
      screenNum = 1;
    });
  }

  void _buttonFunc() async {
    if (screenNum == 1) {
      if (role == 'customer') {
        setState(() {
          screenNum = 2;
        });
      } else if (role == 'worker') {
        setState(() => loading = true);
        await createOrderFunction(
            context, items, userData, _selectedItems, shop, paymentMethod, role, plusTime);
        setState(() => loading = false);
      }
    } else {
      if (role == 'customer') {
        setState(() => loading = true);
        await createOrderFunction(
            context, items, userData, _selectedItems, shop, paymentMethod, role, plusTime);
        setState(() => loading = false);
      }
    }
  }

  Widget _text(String string, double size, FontWeight fontWeight, {Color color = Colors.black}) {
    return Text(
      string,
      style: TextStyle(color: color, fontSize: size, fontWeight: fontWeight),
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

  Widget _orderDelivery(
    List<Shop> shops,
    double deviceWidth,
    UserData userData,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: Responsive.height(8, context)),
          _text(AppStringValues.orderTime, 16, FontWeight.normal),
          SizedBox(height: Responsive.height(1, context)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            width: deviceWidth > kDeviceUpperWidthTreshold ? Responsive.width(60, context) : null,
            child: Slider.adaptive(
              value: plusTime,
              onChanged: (val) => setState(() => plusTime = val),
              min: 5,
              max: 30,
              divisions: 25,
              activeColor: Colors.black,
            ),
          ),
          Center(
            child: Text(
              'Za ${plusTime.toInt()} min',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
          SizedBox(height: Responsive.height(4, context)),
          _text(AppStringValues.paymentMethod, 16, FontWeight.normal),
          SizedBox(height: Responsive.height(1, context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => paymentMethod = 1),
                child: Text(AppStringValues.withCard),
                style: TextButton.styleFrom(
                  backgroundColor: paymentMethod == 1 ? Colors.black : Colors.white,
                  primary: paymentMethod == 1 ? Colors.white : Colors.grey,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => paymentMethod = 2),
                child: Text('${AppStringValues.withTokens} (${userData.tokens})'),
                style: TextButton.styleFrom(
                  backgroundColor: paymentMethod == 2 ? Colors.black : Colors.white,
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
