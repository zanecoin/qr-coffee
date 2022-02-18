import 'package:qr_coffee/models/shop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopDatabase {
  ShopDatabase({this.companyId, this.shopId});
  final String? companyId;
  final String? shopId;

  CollectionReference _getCollection() {
    return FirebaseFirestore.instance.collection('companies').doc(companyId).collection('shops');
  }

  Future addShop(String address, String city, String openingHours, String company) async {
    bool active = false;
    CollectionReference shopCollection = _getCollection();
    DocumentReference _docRef = await shopCollection.add({
      'uid': '',
      'address': address,
      'coordinates': '',
      'active': active,
      'opening_hours': openingHours,
      'city': city,
      'company': company,
      'companyId': this.companyId,
    });
    await shopCollection.doc(_docRef.id).update({'uid': _docRef.id});
    return _docRef;
  }

  Future updateShopData(String uid, String address, String coordinates, bool active, String city,
      String openingHours, String company) async {
    CollectionReference shopCollection = _getCollection();
    return await shopCollection.doc(uid).set({
      'uid': uid,
      'address': address,
      'coordinates': '',
      'active': active,
      'opening_hours': openingHours,
      'city': city,
      'company': company,
      'companyId': this.companyId,
    });
  }

  Future updateShopStatus(String uid, bool active) async {
    CollectionReference shopCollection = _getCollection();
    return await shopCollection.doc(uid).update({'active': active});
  }

  Future deleteShop(String uid) async {
    CollectionReference shopCollection = _getCollection();
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
        company: (doc.data() as dynamic)['company'],
        companyId: (doc.data() as dynamic)['companyId'],
      );
    }).toList();
  }

  Shop _shopFromSnapshot(DocumentSnapshot snapshot) {
    return Shop(
      uid: (snapshot.data() as dynamic)['uid'],
      address: (snapshot.data() as dynamic)['address'],
      coordinates: (snapshot.data() as dynamic)['coordinates'],
      active: (snapshot.data() as dynamic)['active'],
      openingHours: (snapshot.data() as dynamic)['opening_hours'],
      city: (snapshot.data() as dynamic)['city'],
      company: (snapshot.data() as dynamic)['company'],
      companyId: (snapshot.data() as dynamic)['companyId'],
    );
  }

  // Get shop list stream.
  Stream<List<Shop>> get shopList {
    CollectionReference shopCollection = _getCollection();
    return shopCollection.snapshots().map(_shopsFromSnapshot);
  }

  // Get specific shop stream.
  Stream<Shop> get shop {
    CollectionReference shopCollection = _getCollection();
    if (shopId == null) {
      print('Error: add parameter shopId - ShopDatabase(shopId: shopId).shop');
    }
    return shopCollection.doc(shopId).snapshots().map(_shopFromSnapshot);
  }
}
