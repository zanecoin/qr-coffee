import 'package:cafe_app/models/place.dart';
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/service/database.dart';
import 'package:cafe_app/shared/animated_toggle.dart';
import 'package:cafe_app/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:cafe_app/shared/theme_provider.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool darkMode = false;
  bool showPlaces = false;
  Object? _currentPlace;
  late UserData userData;
  late ThemeProvider themeProvider;
  late List<Place> places = [];

  @override
  Widget build(BuildContext context) {
    // get currently logged user and theme provider
    final user = Provider.of<User?>(context);
    themeProvider = Provider.of<ThemeProvider>(context);

    return StreamBuilder2<List<Place>, UserData>(
      streams: Tuple2(DatabaseService().placeList,
          DatabaseService(uid: user!.uid).userData),
      builder: (context, snapshots) {
        if (snapshots.item1.hasData && snapshots.item2.hasData) {
          places = snapshots.item1.data!;
          userData = snapshots.item2.data!;
          showPlaces = userData.stand == '' ? false : true;
          darkMode = !themeProvider.isLightTheme;

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 22),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: Text(
                'Nastavení',
              ),
              centerTitle: true,
              elevation: 5,
            ),
            body: Container(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tmavý režim', style: TextStyle(fontSize: 16)),
                      animatedToggle(true, darkMode, callback),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (userData.role == 'worker')
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Aktivovat stanoviště',
                                style: TextStyle(fontSize: 16)),
                            _currentPlace.toString() == 'null' &&
                                    userData.stand == ''
                                ? disabledAnimatedToggle()
                                : animatedToggle(false, showPlaces, callback),
                          ],
                        ),
                        SizedBox(height: 10),
                        userData.stand == ''
                            ? _placeSelect(places)
                            : _placeBanner(),
                      ],
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

  callback(bool themeToggle) {
    if (themeToggle) {
      _toggleTheme();
    } else {
      _togglePlace();
    }
  }

  _togglePlace() async {
    String stand;
    bool active;
    Place? finalPlace;

    if (userData.stand == '') {
      stand = _currentPlace.toString();
      active = true;
      for (var place in places) {
        if (place.address == _currentPlace.toString()) {
          finalPlace = place;
        }
      }
    } else {
      stand = '';
      active = false;
      for (var place in places) {
        if (place.address == userData.stand) {
          finalPlace = place;
        }
      }
    }

    await DatabaseService(uid: userData.uid).updateUserData(
      userData.name,
      userData.surname,
      userData.email,
      userData.role,
      userData.spz,
      stand,
      userData.card,
    );

    try {
      await DatabaseService(uid: finalPlace!.uid)
          .updatePlaceData(finalPlace.address, finalPlace.coordinate, active);
    } catch (e) {
      print(e);
    }

    setState(() {
      showPlaces = !showPlaces;
    });
  }

  _toggleTheme() async {
    setState(() {
      darkMode = !darkMode;
    });
    await themeProvider.toggleThemeData();
    setState(() {});
  }

  Widget _placeBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade200,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.place,
              color: Colors.black,
              size: 25,
            ),
            SizedBox(width: 5),
            Text(
              userData.stand,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  Widget _placeSelect(List<Place> places) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField(
                hint: Text('Vyberte odběrové místo'),
                value: _currentPlace,
                items: places.map((place) {
                  return DropdownMenuItem(
                    child: Row(
                      children: [
                        Icon(
                          Icons.place,
                          color: place.active ? Colors.grey : Colors.black,
                        ),
                        Text(
                          ' ${place.address}',
                          style: TextStyle(
                            color: place.active ? Colors.grey : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    value: place.address,
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _currentPlace = val!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
