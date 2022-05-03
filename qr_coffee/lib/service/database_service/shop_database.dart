import 'package:qr_coffee/models/shop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopDatabase {
  ShopDatabase({this.companyID, this.shopID});
  final String? companyID;
  final String? shopID;

  CollectionReference _getCollection() {
    return FirebaseFirestore.instance.collection('companies').doc(companyID).collection('shops');
  }

  final Query allShops = FirebaseFirestore.instance.collectionGroup('shops');

  Future addShop(String address, String city, String openingHours, String company) async {
    CollectionReference shopCollection = _getCollection();
    DocumentReference _docRef = await shopCollection.add({
      'shopID': '',
      'address': address,
      'coordinates': '',
      'opening_hours': openingHours,
      'city': city,
      'company': company,
      'companyID': this.companyID,
      'soldoutProducts': [],
    });
    await shopCollection.doc(_docRef.id).update({'shopID': _docRef.id});
    return _docRef;
  }

  Future updateShopData(String shopID, String address, String coordinates, String city,
      String openingHours, String company) async {
    CollectionReference shopCollection = _getCollection();
    return await shopCollection.doc(shopID).set({
      'shopID': shopID,
      'address': address,
      'coordinates': '',
      'opening_hours': openingHours,
      'city': city,
      'company': company,
      'companyID': this.companyID,
      'soldoutProducts': [],
    });
  }

  Future updateSoldoutProducts(List<dynamic> soldoutProducts) async {
    CollectionReference shopCollection = _getCollection();
    return await shopCollection.doc(shopID).update({'soldoutProducts': soldoutProducts});
  }

  Future deleteShop(String shopID) async {
    CollectionReference shopCollection = _getCollection();
    return await shopCollection.doc(shopID).delete();
  }

  List<Shop> _shopListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Shop(
        shopID: (doc.data() as dynamic)['shopID'] ?? '',
        address: (doc.data() as dynamic)['address'] ?? '',
        coordinates: (doc.data() as dynamic)['coordinates'] ?? '',
        openingHours: (doc.data() as dynamic)['opening_hours'] ?? '',
        city: (doc.data() as dynamic)['city'] ?? '',
        company: (doc.data() as dynamic)['company'] ?? '',
        companyID: (doc.data() as dynamic)['companyID'] ?? '',
        soldoutProducts: (doc.data() as dynamic)['soldoutProducts'] ?? [],
      );
    }).toList();
  }

  Shop _shopFromSnapshot(DocumentSnapshot snapshot) {
    return Shop(
      shopID: (snapshot.data() as dynamic)['shopID'] ?? '',
      address: (snapshot.data() as dynamic)['address'] ?? '',
      coordinates: (snapshot.data() as dynamic)['coordinates'] ?? '',
      openingHours: (snapshot.data() as dynamic)['opening_hours'] ?? '',
      city: (snapshot.data() as dynamic)['city'] ?? '',
      company: (snapshot.data() as dynamic)['company'] ?? '',
      companyID: (snapshot.data() as dynamic)['companyID'] ?? '',
      soldoutProducts: (snapshot.data() as dynamic)['soldoutProducts'] ?? [],
    );
  }

  // Get shop list stream from specific company.
  Stream<List<Shop>> get shopList {
    CollectionReference shopCollection = _getCollection();
    return shopCollection.snapshots().map(_shopListFromSnapshot);
  }

  // Get shop list stream from all companies.
  Stream<List<Shop>> get fullShopList {
    return allShops.snapshots().map(_shopListFromSnapshot);
  }

  // Get specific shop stream.
  Stream<Shop>? get shop {
    CollectionReference shopCollection = _getCollection();
    if (shopID == null || shopID == '') {
      print('Error: missing parameter shopID - ShopDatabase(shopID: shopID).shop');
      return null;
    }
    return shopCollection.doc(shopID).snapshots().map(_shopFromSnapshot);
  }
}
