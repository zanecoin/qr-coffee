import 'package:qr_coffee/models/company.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String _tempId = 'c9wzSTR2HEnYxmgEC8Wl';

class CompanyDatabase {
  final String? uid;
  CompanyDatabase({this.uid});

  final CollectionReference companyCollection = FirebaseFirestore.instance.collection('companies');

  Future updateCompany(String name, String phone, String email) async {
    return await companyCollection.doc(uid).update({
      'name': name,
      'phone': phone,
      'email': email,
    });
  }

  Company _companyFromSnapshot(DocumentSnapshot snapshot) {
    return Company(
      name: (snapshot.data() as dynamic)['name'],
      phone: (snapshot.data() as dynamic)['phone'],
      email: (snapshot.data() as dynamic)['email'],
      headquarters: (snapshot.data() as dynamic)['headquarters'],
      uid: (snapshot.data() as dynamic)['uid'],
      admin: (snapshot.data() as dynamic)['admin'],
      worker: (snapshot.data() as dynamic)['worker'],
    );
  }

  List<Company> _companyListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Company(
        name: (doc.data() as dynamic)['name'],
        phone: (doc.data() as dynamic)['phone'],
        email: (doc.data() as dynamic)['email'],
        headquarters: (doc.data() as dynamic)['headquarters'],
        uid: (doc.data() as dynamic)['uid'],
        admin: (doc.data() as dynamic)['admin'],
        worker: (doc.data() as dynamic)['worker'],
      );
    }).toList();
  }

  // GET COMPANY DOCUMENT STREAM
  Stream<Company> get company {
    return companyCollection.doc(_tempId).snapshots().map(_companyFromSnapshot);
  }

  // GET COMPANY DOCUMENT STREAM
  Stream<List<Company>> get companyList {
    return companyCollection.snapshots().map(_companyListFromSnapshot);
  }
}
