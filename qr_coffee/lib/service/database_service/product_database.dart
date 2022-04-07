import 'package:qr_coffee/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDatabase {
  final String? productID;
  final String? companyID;
  ProductDatabase({required this.companyID, this.productID});

  CollectionReference _getCollection() {
    return FirebaseFirestore.instance.collection('companies').doc(companyID).collection('products');
  }

  List<Product> _productListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Product(
        name: (doc.data() as dynamic)['name'],
        price: (doc.data() as dynamic)['price'],
        type: _getEnumType((doc.data() as dynamic)['type']),
        productID: (doc.data() as dynamic)['productID'],
        pictureURL: (doc.data() as dynamic)['picture'],
      );
    }).toList();
  }

  // Get product list stream.
  Stream<List<Product>> get products {
    return _getCollection().snapshots().map(_productListFromSnapshot);
  }

  ProductType _getEnumType(String strType) {
    if (strType == 'drink') {
      return ProductType.drink;
    } else {
      return ProductType.food;
    }
  }
}
