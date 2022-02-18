import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_coffee/models/user.dart';

class UserDatabase {
  final String? uid;
  UserDatabase({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name, String surname, String email, String role, int tokens,
      bool switching, int numOrders, String company) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'surname': surname,
      'email': email,
      'role': role,
      'tokens': tokens,
      'switching': switching,
      'numOrders': numOrders,
      'company': company,
    });
  }

  Future updateUserTokens(int tokens) async {
    return await userCollection.doc(uid).update({
      'tokens': tokens,
    });
  }

  Future updateNumOrders(int numOrders) async {
    return await userCollection.doc(uid).update({
      'numOrders': numOrders,
    });
  }

  Future updateRole(String role) async {
    return await userCollection.doc(uid).update({
      'role': role,
    });
  }

  Future updateName(String name, String surname) async {
    return await userCollection.doc(uid).update({
      'name': name,
      'surname': surname,
    });
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid!,
      name: (snapshot.data() as dynamic)['name'],
      surname: (snapshot.data() as dynamic)['surname'],
      email: (snapshot.data() as dynamic)['email'],
      role: (snapshot.data() as dynamic)['role'],
      tokens: (snapshot.data() as dynamic)['tokens'],
      switching: (snapshot.data() as dynamic)['switching'],
      numOrders: (snapshot.data() as dynamic)['numOrders'],
      company: (snapshot.data() as dynamic)['company'],
    );
  }

  List<UserData> _userDataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserData(
        uid: uid!,
        name: (doc.data() as dynamic)['name'],
        surname: (doc.data() as dynamic)['surname'],
        email: (doc.data() as dynamic)['email'],
        role: (doc.data() as dynamic)['role'],
        tokens: (doc.data() as dynamic)['tokens'],
        switching: (doc.data() as dynamic)['switching'],
        numOrders: (doc.data() as dynamic)['numOrders'],
        company: (doc.data() as dynamic)['company'],
      );
    }).toList();
  }

  // Get user document stream.
  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  // Get user list stream.
  Stream<List<UserData>> get userDataList {
    return userCollection.snapshots().map(_userDataListFromSnapshot);
  }
}
