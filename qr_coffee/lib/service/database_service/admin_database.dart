import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_coffee/models/admin.dart';

class AdminDatabase {
  final String? userID;
  AdminDatabase({this.userID});

  final CollectionReference adminCollection = FirebaseFirestore.instance.collection('admins');

  Future updateAdminData(String companyID) async {
    return await adminCollection.doc(userID).set({'companyID': companyID});
  }

  Admin _adminDataFromSnapshot(DocumentSnapshot snapshot) {
    return Admin(
      userID: userID!,
      companyID: (snapshot.data() as dynamic)['companyID'] ?? '',
    );
  }

  List<Admin> _adminDataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Admin(
        userID: userID!,
        companyID: (doc.data() as dynamic)['companyID'] ?? '',
      );
    }).toList();
  }

  // Get admin document stream.
  Stream<Admin> get admin {
    return adminCollection.doc(userID).snapshots().map(_adminDataFromSnapshot);
  }

  // Get admin list stream.
  Stream<List<Admin>> get adminList {
    return adminCollection.snapshots().map(_adminDataListFromSnapshot);
  }
}
