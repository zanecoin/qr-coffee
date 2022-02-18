import 'package:community_material_icon/community_material_icon.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_company/company_products.dart';
import 'package:qr_coffee/screens/app_company/company_settings.dart';
import 'package:qr_coffee/screens/app_company/company_shops.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/stats.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key, required this.databaseImages}) : super(key: key);

  final List<Map<String, dynamic>> databaseImages;

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      CompanySettings(),
      CompanyShops(databaseImages: widget.databaseImages),
      CompanyProducts(databaseImages: widget.databaseImages),
      Stats(),
    ];

    final user = Provider.of<User?>(context);

    return Scaffold(
      body: StreamBuilder<UserData>(
        stream: UserDatabase(uid: user!.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData userData = snapshot.data!;
            return StreamProvider<Company>(
              create: (context) => CompanyDatabase(uid: userData.company).company,
              initialData: Company.initialData(),
              catchError: (_, __) => Company.initialData(),
              child: IndexedStack(index: _currentIndex, children: screens),
            );
          } else {
            return Loading();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade300,
        showUnselectedLabels: false,
        selectedFontSize: 12.0,
        iconSize: 30.0,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Nastavení'),
          BottomNavigationBarItem(icon: Icon(Icons.store_outlined), label: 'Provozovny'),
          BottomNavigationBarItem(icon: Icon(Icons.coffee), label: 'Produkty'),
          BottomNavigationBarItem(
              icon: Icon(CommunityMaterialIcons.chart_box_outline), label: 'Přehled'),
        ],
      ),
    );
  }
}
