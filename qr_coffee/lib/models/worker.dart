import 'package:qr_coffee/models/user.dart';

class Worker extends UserData {
  Worker({
    required this.companyID,
    required String userID,
    String role = 'worker',
  }) : super(role: role, userID: userID);

  final String companyID;

  factory Worker.initialData() {
    return Worker(companyID: '', userID: '');
  }
}
