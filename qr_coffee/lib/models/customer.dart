import 'package:qr_coffee/models/user.dart';
import 'package:qr_coffee/service/database_service/customer_database.dart';

class Customer extends UserData {
  Customer({
    required this.name,
    required this.surname,
    required this.email,
    required this.credits,
    required String userID,
    UserRole role = UserRole.customer,
  }) : super(userID: userID, role: role);

  final String name;
  final String surname;
  final String email;
  final int credits;

  updateName(String name, String surname) {
    CustomerDatabase(userID: this.userID).updateName(name, surname);
  }

  updateCredits(int credits) {
    CustomerDatabase(userID: this.userID).updateCredits(credits);
  }

  factory Customer.initialData() {
    return Customer(name: '', surname: '', email: '', credits: 0, userID: '');
  }
}
