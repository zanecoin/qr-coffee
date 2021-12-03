import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:qr_coffee/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:qr_coffee/models/article.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/loading.dart';

class QRTokens extends StatefulWidget {
  @override
  _QRTokensState createState() => _QRTokensState();
}

class _QRTokensState extends State<QRTokens> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Article>>(
      stream: DatabaseService().articleList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Article> articles = snapshot.data!;

          return Scaffold(
            appBar: customAppBar(context, title: Text('')),
            body: Container(
              child: Center(
                child: Text(
                  CzechStrings.myTokens,
                ),
              ),
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }
}
