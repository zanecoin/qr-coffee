import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database.dart';
import 'package:qr_coffee/shared/custom_app_bar.dart';
import 'package:qr_coffee/shared/custom_buttons.dart';
import 'package:qr_coffee/shared/loading.dart';
import 'package:qr_coffee/shared/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:provider/provider.dart';

class CardForm extends StatefulWidget {
  @override
  _CardFormState createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String _cardNumber = '';
  String _expiryDate = '';
  String _cardHolderName = '';
  String _cvvCode = '';
  bool isCvvFocused = false;

  @override
  Widget build(BuildContext context) {
    // get currently logged user and theme provider
    final user = Provider.of<User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // get data streams
    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user!.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData userData = snapshot.data!;

          return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: customAppBar(context,
                  title: Text('Přidat kartu'), elevation: 0),
              body: Builder(builder: (BuildContext context) {
                return SafeArea(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: CreditCardWidget(
                            cardNumber: _cardNumber,
                            expiryDate: _expiryDate,
                            cardHolderName: _cardHolderName.toUpperCase(),
                            cvvCode: _cvvCode,
                            showBackView: isCvvFocused,
                            height: 175,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CreditCardForm(
                                  formKey: _key,
                                  themeColor: Colors.red,
                                  onCreditCardModelChange:
                                      onCreditCardModelChange,
                                  obscureCvv: true,
                                  obscureNumber: true,
                                  cardNumber: _cardNumber,
                                  expiryDate: _expiryDate,
                                  cardHolderName: _cardHolderName.toUpperCase(),
                                  cvvCode: _cvvCode,
                                  cardNumberDecoration: _customDecoration(
                                    'Number',
                                    'XXXX XXXX XXXX XXXX',
                                  ),
                                  expiryDateDecoration: _customDecoration(
                                    'Expired Date',
                                    'XX/XX',
                                  ),
                                  cvvCodeDecoration: _customDecoration(
                                    'CVV',
                                    'XXX',
                                  ),
                                  cardHolderDecoration: _customDecoration(
                                    'Card Holder',
                                    '',
                                  ),
                                ),
                                SizedBox(height: 10),
                                _add(userData, context),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }));
        } else {
          return Loading();
        }
      },
    );
  }

  // VISUAL CARD MODEL INFO
  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      _cardNumber = creditCardModel.cardNumber;
      _expiryDate = creditCardModel.expiryDate;
      _cardHolderName = creditCardModel.cardHolderName;
      _cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  InputDecoration _customDecoration(String label, String hint) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey),
      fillColor: Colors.white,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 2.0),
      ),
    );
  }

  // CONFIRM NEW CARD
  Widget _add(UserData userData, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton.icon(
        icon: Icon(
          CommunityMaterialIcons.plus_box_outline,
          color: Colors.white,
        ),
        label: Text(
          'Přidat platební kartu',
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
        onPressed: () async {
          if (_cardNumber.length == 19 &&
              _expiryDate.length == 5 &&
              _cardHolderName != '' &&
              _cvvCode.length > 2) {
            // CREATE CARD DOCUMENT
            DocumentReference _docRef =
                await DatabaseService(uid: userData.uid).updateCards(
              _cardNumber.trim(),
              _expiryDate.trim(),
              _cardHolderName.toUpperCase().trim(),
              _cvvCode.trim(),
            );
            // GET DOCUMENT ID
            DatabaseService(uid: userData.uid).setCardID(
              _docRef.id,
              _cardNumber.trim(),
              _expiryDate.trim(),
              _cardHolderName.toUpperCase().trim(),
              _cvvCode.trim(),
            );
            // UPDATE USERS LAST CARD
            await DatabaseService(uid: userData.uid).updateUserData(
              userData.name,
              userData.surname,
              userData.email,
              userData.role,
              userData.spz,
              userData.stand,
              1,
            );

            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Kartu nelze přidat, zkontrolujte prosím, že jsou všechna pole správně vyplněná.'),
                duration: Duration(milliseconds: 3000),
              ),
            );
          }
        },
        style: customButtonStyle(),
      ),
    );
  }
}
