import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database_service/customer_database.dart';

class Customer extends UserData {
  Customer({
    required this.name,
    required this.surname,
    required this.email,
    required this.tokens,
    required String userID,
    String role = 'customer',
  }) : super(userID: userID, role: role);

  final String name;
  final String surname;
  final String email;
  final int tokens;

  updateName(String name, String surname) {
    CustomerDatabase(userID: this.userID).updateName(name, surname);
  }

  updateTokens(int tokens) {
    CustomerDatabase(userID: this.userID).updateTokens(tokens);
  }

  factory Customer.initialData() {
    return Customer(name: '', surname: '', email: '', tokens: 0, userID: '');
  }
}
