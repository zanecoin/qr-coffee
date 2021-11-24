import 'package:qr_coffee/screens/customer_app/customer_home.dart';
import 'package:qr_coffee/screens/worker_app/worker_home.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/authenticate/authenticate.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/loading.dart';
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
