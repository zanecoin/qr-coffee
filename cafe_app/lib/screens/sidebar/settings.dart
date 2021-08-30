import 'package:flutter/material.dart';
import 'package:cafe_app/shared/theme_provider.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool toggleValue = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    toggleValue = !themeProvider.isLightTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 22),
          onPressed: (){
            Navigator.pop(context);
          }
        ),
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
                _animatedToggle(themeProvider),
              ],
            )
          ],
        ),
      )
    );
  }

  Widget _animatedToggle(ThemeProvider themeProvider){
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      height: 30.0,
      width: 70.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: toggleValue ? Colors.greenAccent[100] : Colors.redAccent[100]!.withOpacity(0.5),
      ),
      child: InkWell(
        onTap: () async{
          toggleButton();
          await themeProvider.toggleThemeData();
          setState(() {});
        },
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOutBack,
              top: 2.5,
              left: toggleValue ? 40.0 : 0.0,
              right: toggleValue ? 0.0 : 40.0,
              child: AnimatedSwitcher(
                duration: Duration(microseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation){
                  return ScaleTransition(child: child, scale: animation);
                },
                child: toggleValue ? Icon(Icons.check_circle, color: Colors.green, size: 25.0,
                  key: UniqueKey(),
                ) : Icon(Icons.remove_circle_outline, color: Colors.red, size: 25.0,
                  key: UniqueKey(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  toggleButton(){
    setState(() {
      toggleValue = !toggleValue;
    });
  }
}