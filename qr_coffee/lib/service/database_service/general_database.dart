import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_coffee/models/user.dart';

class GeneralDatabase {
  final String userID;
  GeneralDatabase({required this.userID});

  DocumentReference _getCustomer() {
    return FirebaseFirestore.instance.collection('customers').doc(userID);
  }

  DocumentReference _getWorker() {
    return FirebaseFirestore.instance.collection('workers').doc(userID);
  }

  DocumentReference _getAdmin() {
    return FirebaseFirestore.instance.collection('admins').doc(userID);
  }

  Future<bool> _getAnswer(docRef) async {
    bool answer = false;
    await docRef.get().then((doc) => {if (doc.exists) answer = true});
    return answer;
  }

  Map<UserRole, Future<bool>> getAvailableRoles() {
    return {
      UserRole.customer: _getAnswer(_getCustomer()),
      UserRole.worker: _getAnswer(_getWorker()),
      UserRole.admin: _getAnswer(_getAdmin()),
    };
  }
}
