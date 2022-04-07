import 'package:community_material_icon/community_material_icon.dart';
import 'package:provider/provider.dart';
import 'package:qr_coffee/models/admin.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/app_company/app_admin/admin_home_body.dart/statistics/statistics.dart';
import 'package:qr_coffee/screens/app_company/common/company_products.dart';
import 'package:qr_coffee/screens/settings/admin_settings.dart';
import 'package:qr_coffee/screens/app_company/common/company_shops.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/service/database_service/database_imports.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key, required this.databaseImages}) : super(key: key);
  final List<Map<String, dynamic>> databaseImages;

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [AdminSettings(), CompanyShops(), CompanyProducts(), Statistics()];

    final themeProvider = Provider.of<ThemeProvider>(context);
    final userFromAuth = Provider.of<UserFromAuth?>(context);

    return Scaffold(
      backgroundColor: themeProvider.themeData().backgroundColor,
      body: StreamBuilder<Admin>(
        stream: AdminDatabase(userID: userFromAuth!.userID).admin,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Admin admin = snapshot.data!;
            return MultiProvider(
              providers: [
                StreamProvider<Company>(
                  create: (context) => CompanyDatabase(companyID: admin.companyID).company,
                  initialData: Company.initialData(),
                  catchError: (_, __) => Company.initialData(),
                ),
                StreamProvider<Admin>(
                  create: (context) => AdminDatabase(userID: userFromAuth.userID).admin,
                  initialData: Admin.initialData(),
                  catchError: (_, __) => Admin.initialData(),
                ),
              ],
              child: IndexedStack(index: _currentIndex, children: screens),
            );
          } else {
            return Loading();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: themeProvider.themeData().backgroundColor,
        selectedItemColor: themeProvider.themeAdditionalData().selectedColor,
        unselectedItemColor: themeProvider.themeAdditionalData().unselectedColor,
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
