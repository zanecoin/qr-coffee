import 'package:qr_coffee/models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String _tempId = 'c9wzSTR2HEnYxmgEC8Wl';

class CompanyOrderDatabase {
  CompanyOrderDatabase({this.uid});
  final String? uid;

  CollectionReference _getPassiveOrderCollection() {
    String date = DateFormat('yyyy_MM_dd').format(DateTime.now());
    return FirebaseFirestore.instance
        .collection('companies')
        .doc(_tempId)
        .collection('passive_orders')
        .doc('$date')
        .collection('orders');
  }

  final CollectionReference activeOrderCollection =
      FirebaseFirestore.instance.collection('companies').doc(_tempId).collection('active_orders');

  final CollectionReference virtualOrderCollection =
      FirebaseFirestore.instance.collection('companies').doc(_tempId).collection('virtual_orders');

  Future deleteActiveOrder(String orderID) async {
    return await activeOrderCollection.doc(orderID).delete();
  }

  Future createActiveOrder(
    String status,
    List items,
    int price,
    String pickUpTime,
    String username,
    String shop,
    String company,
    String orderID,
    String userID,
    String shopID,
    String companyID,
    String day,
  ) async {
    DocumentReference _docRef = await activeOrderCollection.add({
      'status': status,
      'items': items,
      'price': price,
      'pickUpTime': pickUpTime,
      'username': username,
      'shop': shop,
      'company': company,
      'orderID': orderID,
      'userID': userID,
      'shopID': shopID,
      'companyID': companyID,
      'day': day,
    });
    updateorderID(_docRef.id, status);
    return _docRef;
  }

  Future createPassiveOrder(
    String status,
    List items,
    int price,
    String pickUpTime,
    String username,
    String shop,
    String company,
    String orderID,
    String userID,
    String shopID,
    String companyID,
    String day,
  ) async {
    CollectionReference passiveOrderCollection = _getPassiveOrderCollection();
    if (orderID == '') {
      DocumentReference _docRef = await passiveOrderCollection.add({
        'status': status,
        'items': items,
        'price': price,
        'pickUpTime': pickUpTime,
        'username': username,
        'shop': shop,
        'company': company,
        'orderID': orderID,
        'userID': userID,
        'shopID': shopID,
        'companyID': companyID,
        'day': day,
      });
      updateorderID(_docRef.id, status);
      return _docRef;
    } else {
      return await passiveOrderCollection.doc(orderID).set({
        'status': status,
        'items': items,
        'price': price,
        'pickUpTime': pickUpTime,
        'username': username,
        'shop': shop,
        'company': company,
        'orderID': orderID,
        'userID': userID,
        'shopID': shopID,
        'companyID': companyID,
        'day': day,
      });
    }
  }

  Future createVirtualOrder(
    String status,
    List items,
    int price,
    String pickUpTime,
    String username,
    String shop,
    String company,
    String orderID,
    String userID,
    String shopID,
    String companyID,
    String day,
  ) async {
    return await virtualOrderCollection.add({
      'status': status,
      'items': items,
      'price': price,
      'pickUpTime': pickUpTime,
      'username': username,
      'shop': shop,
      'company': company,
      'orderID': orderID,
      'userID': userID,
      'shopID': shopID,
      'companyID': companyID,
      'day': day,
    });
  }

  // Set id for new virtual order.
  Future updateVirtualorderID(
    String orderID,
  ) async {
    return await virtualOrderCollection.doc(orderID).update({
      'orderID': orderID,
    });
  }

  // Set id for new order
  Future updateorderID(
    String orderID,
    String status,
  ) async {
    if (status == 'ACTIVE' || status == 'PENDING') {
      return await activeOrderCollection.doc(orderID).update({
        'orderID': orderID,
      });
    } else {
      CollectionReference passiveOrderCollection = _getPassiveOrderCollection();
      return await passiveOrderCollection.doc(orderID).update({
        'orderID': orderID,
      });
    }
  }

  // Update order status from 'active' to 'ready'.
  Future updateOrderStatus(
    String orderID,
    String status,
  ) async {
    return await activeOrderCollection.doc(orderID).update({
      'status': status,
    });
  }

  // Get order list from database.
  List<Order> _OrderListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Order(
        status: (doc.data() as dynamic)['status'],
        items: (doc.data() as dynamic)['items'],
        price: (doc.data() as dynamic)['price'],
        pickUpTime: (doc.data() as dynamic)['pickUpTime'],
        username: (doc.data() as dynamic)['username'],
        shop: (doc.data() as dynamic)['shop'],
        company: (doc.data() as dynamic)['company'],
        orderID: (doc.data() as dynamic)['orderID'],
        userID: (doc.data() as dynamic)['userID'],
        shopID: (doc.data() as dynamic)['shopID'],
        companyID: (doc.data() as dynamic)['companyID'],
        day: (doc.data() as dynamic)['day'],
      );
    }).toList();
  }

  // Get specific order from database.
  Order _OrderFromSnapshot(DocumentSnapshot snapshot) {
    return Order(
      status: (snapshot.data() as dynamic)['status'],
      items: (snapshot.data() as dynamic)['items'],
      price: (snapshot.data() as dynamic)['price'],
      pickUpTime: (snapshot.data() as dynamic)['pickUpTime'],
      username: (snapshot.data() as dynamic)['username'],
      shop: (snapshot.data() as dynamic)['shop'],
      company: (snapshot.data() as dynamic)['company'],
      orderID: (snapshot.data() as dynamic)['orderID'],
      userID: (snapshot.data() as dynamic)['userID'],
      shopID: (snapshot.data() as dynamic)['shopID'],
      companyID: (snapshot.data() as dynamic)['companyID'],
      day: (snapshot.data() as dynamic)['day'],
    );
  }

  // Get active orders list stream.
  Stream<List<Order>> get activeOrderList {
    return activeOrderCollection.snapshots().map(_OrderListFromSnapshot);
  }

  // Get passive orders list stream.
  Stream<List<Order>> get passiveOrderList {
    CollectionReference passiveOrderCollection = _getPassiveOrderCollection();
    return passiveOrderCollection.snapshots().map(_OrderListFromSnapshot);
  }

  // Get virtual orders list stream.
  Stream<List<Order>> get virtualOrderList {
    return virtualOrderCollection.snapshots().map(_OrderListFromSnapshot);
  }

  // Get specific active order stream.
  Stream<Order> get order {
    return activeOrderCollection.doc(uid).snapshots().map(_OrderFromSnapshot);
  }
}
