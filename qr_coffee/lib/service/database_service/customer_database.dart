import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_coffee/models/customer.dart';

class CustomerDatabase {
  final String? userID;
  CustomerDatabase({this.userID});

  final CollectionReference customerCollection = FirebaseFirestore.instance.collection('customers');

  Future updateCustomerData(String name, String surname, String email, int tokens) async {
    return await customerCollection.doc(userID).set({
      'name': name,
      'surname': surname,
      'email': email,
      'tokens': tokens,
    });
  }

  Future updateTokens(int tokens) async {
    return await customerCollection.doc(userID).update({'tokens': tokens});
  }

  Future updateName(String name, String surname) async {
    return await customerCollection.doc(userID).update({'name': name, 'surname': surname});
  }

  Customer _customerDataFromSnapshot(DocumentSnapshot snapshot) {
    return Customer(
      userID: userID!,
      name: (snapshot.data() as dynamic)['name'],
      surname: (snapshot.data() as dynamic)['surname'],
      email: (snapshot.data() as dynamic)['email'],
      tokens: (snapshot.data() as dynamic)['tokens'],
    );
  }

  List<Customer> _customerDataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Customer(
        userID: userID!,
        name: (doc.data() as dynamic)['name'],
        surname: (doc.data() as dynamic)['surname'],
        email: (doc.data() as dynamic)['email'],
        tokens: (doc.data() as dynamic)['tokens'],
      );
    }).toList();
  }

  // Get user document stream.
  Stream<Customer> get customer {
    return customerCollection.doc(userID).snapshots().map(_customerDataFromSnapshot);
  }

  // Get user list stream.
  Stream<List<Customer>> get customerList {
    return customerCollection.snapshots().map(_customerDataListFromSnapshot);
  }
}
