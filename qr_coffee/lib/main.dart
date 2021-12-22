import 'dart:async';
import 'package:flutter/services.dart';
import 'package:qr_coffee/shared/constants.dart';
import 'package:qr_coffee/shared/functions.dart';
import 'package:qr_coffee/shared/widgets/image_banner.dart';
import 'package:qr_coffee/shared/widgets/loading.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:qr_coffee/screens/root/wrapper.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/auth.dart';

void main() async {
  // INITIALIZATION
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final appDocumentDirectory =
      await pathProvider.getApplicationDocumentsDirectory();

  Hive.init(appDocumentDirectory.path);

  final settings = await Hive.openBox('settings');
  bool isLightTheme = settings.get('isLightTheme') ?? true;

  // APP START
  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(isLightTheme: isLightTheme),
    child: AppStart(),
  ));
}

// ENSURES THE THEMEPROVIDER IS SET BEFORE THE APP STARTS
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

// THIS WIDGET IS THE ROOT OF THE APPLICATION
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
    return FutureBuilder(
      // INITIALIZE FLUTTERFIRE
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          // TODO: err handling
        }

        // ONCE COMPLETE, SHOW YOUR APPLICATION
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              StreamProvider<User?>(
                create: (context) => AuthService().user,
                initialData: User.initialData(),
              ),
            ],
            child: MaterialApp(
              title: CzechStrings.app_name,
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

// LOADING SCREEN OF THE APP
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
      builder:
          (context, AsyncSnapshot<List<Map<String, dynamic>>> picSnapshot) {
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
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                color: Colors.white,
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: Responsive.height(6, context)),
                    Text(
                      CzechStrings.app_name,
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: Responsive.width(12, context),
                          fontFamily: 'Galada'),
                    ),
                    ImageBanner(path: 'assets/cafe.jpg', size: 'large'),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SpinKitSpinningLines(
                            color: Colors.blue,
                            size: Responsive.height(15, context),
                          ),
                          SizedBox(height: Responsive.height(8, context)),
                          Text(
                            CzechStrings.motto,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
