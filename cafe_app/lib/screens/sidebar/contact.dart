import 'package:flutter/material.dart';
import 'package:cafe_app/models/company.dart';
import 'package:cafe_app/service/database.dart';
import 'package:cafe_app/shared/loading.dart';
import 'package:cafe_app/shared/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  // PHONE AND EMAIL LAUNCHER
  void customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // get data streams
    return StreamBuilder<Company>(
        stream: DatabaseService(uid: 'info_uid').company,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Company company = snapshot.data!;

            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 22),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                title: Text(
                  'Kontakt',
                ),
                centerTitle: true,
                elevation: 0,
              ),
              body: Container(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _circleAvatar(),
                          SizedBox(width: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                company.name,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${company.phone.substring(0, 4)} '
                                '${company.phone.substring(4, 7)} '
                                '${company.phone.substring(7, 10)} '
                                '${company.phone.substring(10)}'
                                '\n${company.email}'
                                '\n${company.headquarters}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    Divider(
                        color: themeProvider.themeMode().textColor,
                        thickness: 0.5,
                        indent: 25,
                        endIndent: 25),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _phoneBtn(company.phone),
                        _mailBtn(company.email),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Loading();
          }
        });
  }

  Widget _circleAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[400]!,
            offset: Offset(0, 0),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 50.0,
        child: Icon(
          Icons.store,
          color: Colors.black,
          size: 60.0,
        ),
      ),
    );
  }

  Widget _phoneBtn(String? phone) {
    return FlatButton(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone, size: 35),
            Text('Zavolat', style: TextStyle(fontSize: 17)),
          ],
        ),
      ),
      onPressed: () {
        customLaunch('tel:$phone');
      },
    );
  }

  Widget _mailBtn(String? email) {
    return FlatButton(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 35),
            Text('Napsat e-mail', style: TextStyle(fontSize: 17)),
          ],
        ),
      ),
      onPressed: () {
        customLaunch('mailto:$email');
      },
    );
  }
}
