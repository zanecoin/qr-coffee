import 'package:qr_coffee/models/customer.dart';
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
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/export_widgets.dart';

class SelectedItemNotifier extends ChangeNotifier {
  List<Product> selectedItems = [];

  void addItem(Product item) {
    selectedItems.insert(0, item);
    notifyListeners();
  }

  void removeItem(int index) {
    selectedItems.removeAt(index);
    notifyListeners();
  }
}

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key, required this.shop}) : super(key: key);
  final Shop shop;

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState(shop: shop);
}

class _CreateOrderScreenState extends State<CreateOrderScreen> with SingleTickerProviderStateMixin {
  _CreateOrderScreenState({required this.shop});
  final Shop shop;

  late UserData userData;
  late List<Product> items;
  late Customer customer;
  bool loading = false;
  double plusTime = 5;
  List<String> choices = [AppStringValues.drink, AppStringValues.food];
  late TabController controller;
  int screenNum = 1;
  int paymentMethod = 2;
  late UserRole role;

  final _selectedItemNotifier = SelectedItemNotifier();

  // Upper tab controller.
  @override
  void initState() {
    super.initState();
    controller = TabController(length: choices.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    _selectedItemNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userFromAuth = Provider.of<UserFromAuth?>(context);
    final double deviceWidth = Responsive.deviceWidth(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return StreamBuilder3<List<Product>, UserData, Customer>(
      streams: Tuple3(
        ProductDatabase(companyID: shop.companyID).products,
        UserDatabase(userID: userFromAuth!.userID).userData,
        CustomerDatabase(userID: userFromAuth.userID).customer,
      ),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData && snapshots.item2.hasData) {
          items = snapshots.item1.data!;
          userData = snapshots.item2.data!;
          role = userData.role;

          if (snapshots.item3.data == null) {
            customer = Customer.initialData();
          } else {
            customer = snapshots.item3.data!;
          }

          return WillPopScope(
            onWillPop: () async => _onWillPop(),
            child: Scaffold(
              backgroundColor: themeProvider.themeData().backgroundColor,
              appBar: AppBar(
                backgroundColor: themeProvider.themeData().backgroundColor,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 22.0,
                    color: themeProvider.themeAdditionalData().textColor,
                  ),
                  onPressed: () {
                    screenNum == 1 ? Navigator.pop(context) : _switchScreenNum();
                  },
                ),
                title: Text(
                  screenNum == 1 ? AppStringValues.orderItems : '',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14.0,
                    color: themeProvider.themeAdditionalData().textColor,
                  ),
                ),
                centerTitle: true,
                elevation: 0.0,
                bottom: screenNum == 1
                    ? TabBar(
                        controller: controller,
                        labelPadding: const EdgeInsets.symmetric(vertical: 0.0),
                        labelColor: themeProvider.themeAdditionalData().textColor,
                        unselectedLabelColor: themeProvider.themeAdditionalData().unselectedColor,
                        indicatorColor: themeProvider.themeAdditionalData().textColor,
                        tabs: choices.map<Widget>((choice) => Tab(text: choice)).toList(),
                      )
                    : null,
              ),
              body: Column(
                children: [
                  Expanded(
                      child: screenNum == 1
                          ? _orderMenu()
                          : _orderDelivery(deviceWidth, customer, themeProvider)),
                  _bottomBar(themeProvider),
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

  void _appendItem(item) {
    //_selectedItems.value.insert(0, item);
    _selectedItemNotifier.addItem(item);
  }

  void _switchScreenNum() {
    setState(() => screenNum = 1);
  }

  void _buttonFunc() async {
    if (screenNum == 1) {
      if (role == UserRole.customer) {
        setState(() => screenNum = 2);
      } else if (role == UserRole.worker) {
        setState(() => loading = true);
        await createOrderFunction(context, items, customer, _selectedItemNotifier.selectedItems,
            shop, paymentMethod, role, plusTime);
        setState(() => loading = false);
      }
    } else {
      if (role == UserRole.customer) {
        setState(() => loading = true);
        await createOrderFunction(context, items, customer, _selectedItemNotifier.selectedItems,
            shop, paymentMethod, role, plusTime);
        setState(() => loading = false);
      }
    }
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
      if (role == UserRole.customer) {
        icon = CommunityMaterialIcons.arrow_right_circle;
      } else if (role == UserRole.worker) {
        icon = CommunityMaterialIcons.upload_outline;
      }
    }
    return icon;
  }

  // Text chooser for submit button.
  String _buttonText() {
    String text = AppStringValues.orderNow;

    if (screenNum == 1) {
      if (role == UserRole.customer) {
        text = AppStringValues.continueOn;
      } else if (role == UserRole.worker) {
        text = AppStringValues.createOrder;
      }
    }
    return text;
  }

  Widget _text(String string, double size, FontWeight fontWeight, ThemeProvider themeProvider) {
    return Text(
      string,
      style: TextStyle(
        color: themeProvider.themeAdditionalData().textColor,
        fontSize: size,
        fontWeight: fontWeight,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _bottomBar(ThemeProvider themeProvider) {
    print('lol');
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        color: themeProvider.themeAdditionalData().containerColor,
        boxShadow: themeProvider.themeAdditionalData().shadow,
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
                    _text(
                      '${AppStringValues.yourOrder}:    ',
                      16.0,
                      FontWeight.normal,
                      themeProvider,
                    ),
                    AnimatedBuilder(
                      animation: _selectedItemNotifier,
                      builder: (_, __) => _text(
                        '${getTotalPrice(items, _selectedItemNotifier.selectedItems)} ${AppStringValues.currency}',
                        22.0,
                        FontWeight.bold,
                        themeProvider,
                      ),
                    ),
                  ],
                ),
                _dynamicChips(themeProvider),
                SizedBox(height: Responsive.height(0.0, context)),
                CustomOutlinedIconButton(
                  function: _buttonFunc,
                  icon: _buttonIcon(),
                  label: _buttonText(),
                  iconColor: Colors.green,
                ),
                SizedBox(height: Responsive.height(2.0, context)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _dynamicChips(ThemeProvider themeProvider) {
    return AnimatedBuilder(
      animation: _selectedItemNotifier,
      builder: (_, __) => (Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 6.0,
            runSpacing: 0.0,
            children: List<Widget>.generate(
              _selectedItemNotifier.selectedItems.length,
              (index) => Chip(
                label: Text(
                  _selectedItemNotifier.selectedItems[index].name,
                  style: TextStyle(
                    color: themeProvider.themeAdditionalData().textColor,
                  ),
                ),
                labelPadding: EdgeInsets.fromLTRB(8.0, 3.0, 0.0, 3.0),
                backgroundColor: themeProvider.themeAdditionalData().chipColor,
                onDeleted: () => _selectedItemNotifier.removeItem(index),
              ),
            ),
          ),
        ),
      )),
    );
  }

  Widget _orderMenu() {
    return FutureBuilder(
      future: loadImages('pictures/products/${shop.companyID}/'),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> picSnapshot) {
        if (picSnapshot.connectionState == ConnectionState.done) {
          return OrderMenu(
            databaseImages: picSnapshot.data!,
            items: items,
            controller: controller,
            onItemTap: _appendItem,
          );
        } else {
          return Loading();
        }
      },
    );
  }

  Widget _orderDelivery(double deviceWidth, Customer customer, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: Responsive.height(8.0, context)),
          _text(AppStringValues.orderTime, 16.0, FontWeight.normal, themeProvider),
          SizedBox(height: Responsive.height(1.0, context)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            width: deviceWidth > kDeviceUpperWidthTreshold ? Responsive.width(60.0, context) : null,
            child: Slider.adaptive(
              value: plusTime,
              onChanged: (val) => setState(() => plusTime = val),
              min: 5.0,
              max: 30.0,
              divisions: 25,
              activeColor: themeProvider.themeAdditionalData().textColor,
            ),
          ),
          Center(
            child: Text(
              'Za ${plusTime.toInt()} min',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: themeProvider.themeAdditionalData().textColor,
              ),
            ),
          ),
          Center(
            child: Text(
              //'${getPickUpTime(plusTime)}',
              '(${getPickUpTime(plusTime).substring(8, 10)}:${getPickUpTime(plusTime).substring(10, 12)})',
              style:
                  TextStyle(fontSize: 17.0, color: themeProvider.themeAdditionalData().textColor),
            ),
          ),
          SizedBox(height: Responsive.height(2.0, context)),
          CustomDivider(),
          SizedBox(height: Responsive.height(4.0, context)),
          _text(AppStringValues.paymentMethod, 16.0, FontWeight.normal, themeProvider),
          SizedBox(height: Responsive.height(1.0, context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => paymentMethod = 1),
                child: Text(AppStringValues.withCard),
                style: TextButton.styleFrom(
                  backgroundColor: paymentMethod == 1
                      ? themeProvider.themeAdditionalData().textColor
                      : themeProvider.themeAdditionalData().backgroundColor,
                  primary: paymentMethod == 1
                      ? themeProvider.themeAdditionalData().backgroundColor
                      : themeProvider.themeAdditionalData().unselectedColor,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => paymentMethod = 2),
                child: Text('${AppStringValues.withCredits} (${customer.credits})'),
                style: TextButton.styleFrom(
                  backgroundColor: paymentMethod == 2
                      ? themeProvider.themeAdditionalData().textColor
                      : themeProvider.themeAdditionalData().backgroundColor,
                  primary: paymentMethod == 2
                      ? themeProvider.themeAdditionalData().backgroundColor
                      : themeProvider.themeAdditionalData().unselectedColor,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.height(2.0, context)),
        ],
      ),
    );
  }
}
