import 'package:cafe_app/screens/customer_app/customer_home.dart';
import 'package:cafe_app/screens/worker_app/worker_home.dart';
import 'package:flutter/material.dart';
import 'package:cafe_app/models/user.dart';
import 'package:cafe_app/screens/authenticate/authenticate.dart';
import 'package:cafe_app/service/database.dart';
import 'package:cafe_app/shared/loading.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // return either Home or Auth widget
    if (user == null || user.uid == '') {
      return Authenticate();
    } else {
      return StreamBuilder<UserData>(
          stream: DatabaseService(uid: user.uid).userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserData userData = snapshot.data!;

              if (userData.role == 'worker') {
                return WorkerHome();
              } else {
                return CustomerHome();
              }
            } else {
              return Loading();
            }
          });
    }
  }
}
