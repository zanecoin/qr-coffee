import 'package:qr_coffee/models/shop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopDatabase {
  final String? uid;
  ShopDatabase({this.uid});

  final CollectionReference shopCollection = FirebaseFirestore.instance
      .collection('companies')
      .doc('c9wzSTR2HEnYxmgEC8Wl')
      .collection('shops');

  Future addShop(String address, String city, String openingHours) async {
    bool active = false;
    DocumentReference _docRef = await shopCollection.add({
      'uid': '',
      'address': address,
      'coordinates': '',
      'active': active,
      'opening_hours': openingHours,
      'city': city,
    });
    await shopCollection.doc(_docRef.id).update({'uid': _docRef.id});
    return _docRef;
  }

  Future updateShopData(String uid, String address, String coordinates, bool active, String city,
      String openingHours) async {
    return await shopCollection.doc(uid).set({
      'uid': '',
      'address': address,
      'coordinates': '',
      'active': active,
      'opening_hours': openingHours,
      'city': city,
    });
  }

  Future updateShopStatus(bool active) async {
    return await shopCollection.doc(uid).update({'active': active});
  }

  Future deleteShop(String uid) async {
    return await shopCollection.doc(uid).delete();
  }

  List<Shop> _shopsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Shop(
        uid: (doc.data() as dynamic)['uid'],
        address: (doc.data() as dynamic)['address'],
        coordinates: (doc.data() as dynamic)['coordinates'],
        active: (doc.data() as dynamic)['active'],
        openingHours: (doc.data() as dynamic)['opening_hours'],
        city: (doc.data() as dynamic)['city'],
      );
    }).toList();
  }

  // Get shop list stream.
  Stream<List<Shop>> get shopList {
    return shopCollection.snapshots().map(_shopsFromSnapshot);
  }
}
