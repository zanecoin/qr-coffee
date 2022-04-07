import 'package:qr_coffee/service/database_service/database_imports.dart';

class UserFromAuth {
  UserFromAuth({required this.userID});

  final String userID;

  factory UserFromAuth.initialData() {
    return UserFromAuth(userID: '');
  }
}

class UserData extends UserFromAuth {
  UserData({required this.role, required String userID}) : super(userID: userID);

  final UserRole role;

  updateRole(UserRole role) {
    UserDatabase(userID: this.userID).updateUserRole(role);
  }
}

enum UserRole { customer, worker, admin }
