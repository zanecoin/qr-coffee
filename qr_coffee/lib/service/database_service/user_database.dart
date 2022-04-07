import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_coffee/models/user.dart';

class UserDatabase {
  final String? userID;
  UserDatabase({this.userID});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future updateUserData(UserRole role) async {
    return await userCollection.doc(userID).set({'role': role});
  }

  Future updateUserRole(UserRole role) async {
    return await userCollection.doc(userID).update({'role': _getStrRole(role)});
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      userID: userID!,
      role: _getEnumRole((snapshot.data() as dynamic)['role']),
    );
  }

  List<UserData> _userDataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserData(
        userID: userID!,
        role: _getEnumRole((doc.data() as dynamic)['role']),
      );
    }).toList();
  }

  // Get user document stream.
  Stream<UserData> get userData {
    return userCollection.doc(userID).snapshots().map(_userDataFromSnapshot);
  }

  // Get user list stream.
  Stream<List<UserData>> get userDataList {
    return userCollection.snapshots().map(_userDataListFromSnapshot);
  }

  UserRole _getEnumRole(String strRole) {
    switch (strRole) {
      case 'customer':
        return UserRole.customer;
      case 'worker':
        return UserRole.worker;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }

  String _getStrRole(UserRole strRole) {
    switch (strRole) {
      case UserRole.customer:
        return 'customer';
      case UserRole.worker:
        return 'worker';
      case UserRole.admin:
        return 'admin';
      default:
        return 'customer';
    }
  }
}
