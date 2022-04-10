import 'package:qr_coffee/models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_coffee/service/database_service/common_functions.dart';

class CompanyOrderDatabase {
  CompanyOrderDatabase({required this.companyID});
  final String? companyID;

  CollectionReference _getTodayPassiveOrderCollection() {
    String date = DateFormat('yyyy_MM_dd').format(DateTime.now());
    return FirebaseFirestore.instance
        .collection('companies')
        .doc(companyID)
        .collection('passive_orders')
        .doc('$date')
        .collection('orders');
  }

  Query _getAllPassiveOrderCollection() {
    return FirebaseFirestore.instance.collectionGroup('orders');
  }

  CollectionReference _getActiveOrderCollection() {
    return FirebaseFirestore.instance
        .collection('companies')
        .doc(companyID)
        .collection('active_orders');
  }

  CollectionReference _getVirtualOrderCollection() {
    String date = DateFormat('yyyy_MM_dd').format(DateTime.now());
    return FirebaseFirestore.instance
        .collection('companies')
        .doc(companyID)
        .collection('virtual_orders')
        .doc('$date')
        .collection('orders');
  }

  Future deleteActiveOrder(String orderID) async {
    return await _getActiveOrderCollection().doc(orderID).delete();
  }

  Future createActiveOrder(
    OrderStatus status,
    Map<dynamic, dynamic> items,
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
    DocumentReference _docRef = await _getActiveOrderCollection().add({
      'status': CommonDatabaseFunctions().getStrStatus(status),
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
    OrderStatus status,
    Map<dynamic, dynamic> items,
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
    CollectionReference passiveOrderCollection = _getTodayPassiveOrderCollection();
    if (orderID == '') {
      DocumentReference _docRef = await passiveOrderCollection.add({
        'status': CommonDatabaseFunctions().getStrStatus(status),
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
        'status': CommonDatabaseFunctions().getStrStatus(status),
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
    OrderStatus status,
    Map<dynamic, dynamic> items,
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
    return await _getVirtualOrderCollection().add({
      'status': CommonDatabaseFunctions().getStrStatus(status),
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
  Future updateVirtualorderID(String orderID) async {
    return await _getVirtualOrderCollection().doc(orderID).update({'orderID': orderID});
  }

  // Set id for new order
  Future updateorderID(String orderID, OrderStatus status) async {
    if (status == OrderStatus.waiting || status == OrderStatus.pending) {
      return await _getActiveOrderCollection().doc(orderID).update({'orderID': orderID});
    } else {
      return await _getTodayPassiveOrderCollection().doc(orderID).update({'orderID': orderID});
    }
  }

  // Update order status from OrderStatus.waiting to OrderStatus.ready.
  Future updateOrderStatus(String orderID, OrderStatus status) async {
    return await _getActiveOrderCollection()
        .doc(orderID)
        .update({'status': CommonDatabaseFunctions().getStrStatus(status)});
  }

  // Get order list from database.
  List<Order> _OrderListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Order(
        status: CommonDatabaseFunctions().getEnumStatus((doc.data() as dynamic)['status']),
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

  // Get active orders list stream.
  Stream<List<Order>> get activeOrderList {
    return _getActiveOrderCollection().snapshots().map(_OrderListFromSnapshot);
  }

  // Get passive orders list stream.
  Stream<List<Order>> get passiveTodayOrderList {
    return _getTodayPassiveOrderCollection().snapshots().map(_OrderListFromSnapshot);
  }

  // Get passive orders list stream.
  Stream<List<Order>> get passiveAllOrderList {
    return _getAllPassiveOrderCollection().snapshots().map(_OrderListFromSnapshot);
  }

  // Get virtual orders list stream.
  Stream<List<Order>> get virtualOrderList {
    return _getVirtualOrderCollection().snapshots().map(_OrderListFromSnapshot);
  }
}
