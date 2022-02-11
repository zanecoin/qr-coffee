import 'package:qr_coffee/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String _tempId = 'c9wzSTR2HEnYxmgEC8Wl';

class ProductDatabase {
  final String? uid;
  ProductDatabase({this.uid});

  final CollectionReference productCollection = FirebaseFirestore.instance
      .collection('companies')
      .doc(_tempId)
      .collection('products');

  Future updateProductData(String uid, int count) async {
    return await productCollection.doc(uid).update({'count': count});
  }

  List<Product> _productListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Product(
        name: (doc.data() as dynamic)['name'],
        price: (doc.data() as dynamic)['price'],
        type: (doc.data() as dynamic)['type'],
        count: (doc.data() as dynamic)['count'],
        uid: (doc.data() as dynamic)['uid'],
        picture: (doc.data() as dynamic)['picture'],
      );
    }).toList();
  }

  // GET PRODUCT LIST STREAM
  Stream<List<Product>> get products {
    return productCollection.snapshots().map(_productListFromSnapshot);
  }
}
