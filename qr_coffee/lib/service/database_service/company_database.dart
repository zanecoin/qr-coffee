import 'package:qr_coffee/models/company.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_coffee/models/shop.dart';

class CompanyDatabase {
  final String? companyID;
  CompanyDatabase({this.companyID});

  final CollectionReference companyCollection = FirebaseFirestore.instance.collection('companies');

  Future updateCompanyData(String name, String phone, String email) async {
    return await companyCollection
        .doc(companyID)
        .update({'name': name, 'phone': phone, 'email': email});
  }

  Future updateCompanyShopNum(int num) async {
    return await companyCollection.doc(companyID).update({'numShops': num});
  }

  Company _companyFromSnapshot(DocumentSnapshot snapshot) {
    return Company(
      name: (snapshot.data() as dynamic)['name'],
      phone: (snapshot.data() as dynamic)['phone'],
      email: (snapshot.data() as dynamic)['email'],
      companyID: (snapshot.data() as dynamic)['companyID'],
      adminID: (snapshot.data() as dynamic)['adminID'],
      workerID: (snapshot.data() as dynamic)['workerID'],
      numShops: (snapshot.data() as dynamic)['numShops'],
    );
  }

  List<Company> _companyListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Company(
        name: (doc.data() as dynamic)['name'],
        phone: (doc.data() as dynamic)['phone'],
        email: (doc.data() as dynamic)['email'],
        companyID: (doc.data() as dynamic)['companyID'],
        adminID: (doc.data() as dynamic)['adminID'],
        workerID: (doc.data() as dynamic)['workerID'],
        numShops: (doc.data() as dynamic)['numShops'],
      );
    }).toList();
  }

  // Get Company document stream.
  Stream<Company> get company {
    return companyCollection.doc(companyID).snapshots().map(_companyFromSnapshot);
  }

  // Get Company list stream.
  Stream<List<Company>> get companyList {
    return companyCollection.snapshots().map(_companyListFromSnapshot);
  }
}
