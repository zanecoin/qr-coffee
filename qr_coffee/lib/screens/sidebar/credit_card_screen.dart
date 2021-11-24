import 'package:qr_coffee/models/credit_card.dart';
import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/screens/sidebar/credit_card_form.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:qr_coffee/shared/custom_buttons.dart';
import 'package:qr_coffee/shared/loading.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:provider/provider.dart';

class CardScreen extends StatefulWidget {
  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  @override
  Widget build(BuildContext context) {
    // get currently logged user and theme provider
    final user = Provider.of<User?>(context);

    // get data streams
    return StreamBuilder<List<UserCard>>(
      stream: DatabaseService(uid: user!.uid).cardList,
      builder: (context, snapshot) {
        return StreamBuilder<UserData>(
          stream: DatabaseService(uid: user.uid).userData,
          builder: (context, snapshot2) {
            if (snapshot.hasData && snapshot2.hasData) {
              List<UserCard> cards = snapshot.data!;
              UserData userData = snapshot2.data!;

              return Scaffold(
                appBar: customAppBar(context, title: Text('Moje karty')),
                body: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (cards.length > 0)
                        CreditCardWidget(
                          cardNumber: cards[0].cardNumber,
                          expiryDate: cards[0].expiryDate,
                          cardHolderName: cards[0].cardHolderName,
                          cvvCode: cards[0].cvvCode,
                          showBackView:
                              false, // true when you want to show cvv(back) view
                        ),
                      SizedBox(height: 10),
                      addCardButton(userData, cards),
                    ],
                  ),
                ),
              );
            } else {
              return Loading();
            }
          },
        );
      },
    );
  }

  // BUTTON FOR ADDING A CREDIT CARD
  Widget addCardButton(UserData userData, List<UserCard> cards) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton.icon(
        icon: Icon(
          userData.card == 0
              ? CommunityMaterialIcons.plus_box_outline
              : CommunityMaterialIcons.minus_box_outline,
          color: Colors.white,
        ),
        label: Text(
          userData.card == 0
              ? 'Přidat platební kartu'
              : 'Odebrat platební kartu',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
        onPressed: () async {
          if (userData.card == 0) {
            Navigator.push(context,
                new MaterialPageRoute(builder: (context) => CardForm()));
          } else {
            DatabaseService(uid: userData.uid).deleteCard(cards[0].uid);
            await DatabaseService(uid: userData.uid).updateUserData(
              userData.name,
              userData.surname,
              userData.email,
              userData.role,
              userData.spz,
              userData.stand,
              0,
            );
          }
        },
        style: customButtonStyle(),
      ),
    );
  }
}
