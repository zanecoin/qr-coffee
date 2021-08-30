import 'dart:async';
import 'package:cafe_app/shared/constants.dart';
import 'package:cafe_app/shared/image_banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cafe_app/screens/root/wrapper.dart';
import 'package:cafe_app/shared/theme_provider.dart';
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/service/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory =
      await pathProvider.getApplicationDocumentsDirectory();

  Hive.init(appDocumentDirectory.path);

  final settings = await Hive.openBox('settings');
  bool isLightTheme = settings.get('isLightTheme') ?? true;

  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(isLightTheme: isLightTheme),
    child: AppStart(),
  ));
}

// Ensures the themeProvider is set before the app starts
class AppStart extends StatelessWidget {
  const AppStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return MyApp(
      themeProvider: themeProvider,
    );
  }
}

// This widget is the root of the application.
class MyApp extends StatefulWidget with WidgetsBindingObserver{
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
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          // TODO: err handling
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              StreamProvider<User?>(create: (context) => AuthService().user,initialData: User.initialData(),),
              //Provider<AuthService>(create: (context) => AuthService(),),
            ],
            child: MaterialApp(
              title: 'Cafe',
              debugShowCheckedModeBanner: false,
              home: SplashScreen(),
              theme: widget.themeProvider.themeData(),
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container();
      },
    );
  }
}

// Loading screen of the app
class SplashScreen extends StatefulWidget {
  SplashScreen({ Key? key}) : super(key : key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // Show homescreen after 3 seconds
    super.initState();
    Timer(Duration(seconds:3), _navigateHome);
  }

  void _navigateHome(){
    Navigator.pushReplacement(
      context, MaterialPageRoute(
        builder: (context) => Wrapper()
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children:<Widget>[
              Container(
                color: Colors.white,
              ),
              Container(
                width: Responsive.width(100, context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: Responsive.height(4, context)),
                    Text(
                      'Fast Coffee',
                      style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.black,
                      fontSize: 60,
                      fontFamily: 'Galada'),
                    ),
                    ImageBanner('assets/cafe.jpg'),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SpinKitCircle(
                            color: Colors.red,
                            size: 100.0,
                          ),
                          SizedBox(height: Responsive.height(8, context)),
                          Text(
                            'Nejrychlejší káva v ČR!',
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
