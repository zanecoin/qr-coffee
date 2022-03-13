import 'dart:async';
import 'package:qr_coffee/root/wrapper.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/auth.dart';
import 'package:qr_coffee/shared/widgets/widget_imports.dart';

// Ensures the themeprovider is set before the app starts.
class AppStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    themeProvider.getCurrentStatusNavigationBarColor();
    return MyApp(
      themeProvider: themeProvider,
    );
  }
}

// This widget is the root of the application.
class MyApp extends StatefulWidget with WidgetsBindingObserver {
  final ThemeProvider themeProvider;
  const MyApp({Key? key, required this.themeProvider}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    // Initialize flutterfire.
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          customSnackbar(context: context, text: 'Firebase error');
        }

        // Once complete, show the application.
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              StreamProvider<UserFromAuth?>(
                create: (context) => AuthService().user,
                initialData: UserFromAuth.initialData(),
              ),
            ],
            child: MaterialApp(
              title: AppStringValues.app_name,
              debugShowCheckedModeBanner: false,
              home: SplashScreen(),
              theme: widget.themeProvider.themeData(),
            ),
          );
        }

        return Container(color: Colors.white);
      },
    );
  }
}

// Loading screen of the app.
class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadImages('pictures/'),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> picSnapshot) {
        if (picSnapshot.connectionState == ConnectionState.done) {
          return Wrapper(databaseImages: picSnapshot.data!);
        } else {
          return Splash();
        }
      },
    );
  }
}

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(color: Colors.white),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: Responsive.height(6.0, context)),
                    Text(
                      AppStringValues.app_name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: Responsive.width(12.0, context),
                        fontFamily: 'Galada',
                      ),
                    ),
                    if (isPortrait) ImageBanner(path: 'assets/cafe.jpg', size: 'large'),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SpinKitSpinningLines(
                            color: Colors.blue,
                            size: Responsive.height(15.0, context),
                          ),
                          SizedBox(height: Responsive.height(8.0, context)),
                          if (isPortrait)
                            Text(AppStringValues.motto,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
