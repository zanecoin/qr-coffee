import 'package:qr_coffee/models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String _tempId = 'c9wzSTR2HEnYxmgEC8Wl';

class CompanyOrderDatabase {
  final String? uid;
  CompanyOrderDatabase({this.uid});

  final CollectionReference activeOrderCollection = FirebaseFirestore.instance
      .collection('companies')
      .doc(_tempId)
      .collection('active_orders');
  final CollectionReference passiveOrderCollection = FirebaseFirestore.instance
      .collection('companies')
      .doc(_tempId)
      .collection('passive_orders');
  final CollectionReference virtualOrderCollection = FirebaseFirestore.instance
      .collection('companies')
      .doc(_tempId)
      .collection('virtual_orders');

  Future deleteActiveOrder(String orderId) async {
    return await activeOrderCollection.doc(orderId).delete();
  }

  Future createActiveOrder(
    String status,
    List items,
    int price,
    String pickUpTime,
    String username,
    String shop,
    String company,
    String orderId,
    String userId,
    String shopId,
    String companyId,
    String day,
    int triggerNum,
  ) async {
    DocumentReference _docRef = await activeOrderCollection.add({
      'status': status,
      'items': items,
      'price': price,
      'pickUpTime': pickUpTime,
      'username': username,
      'shop': shop,
      'company': company,
      'orderId': orderId,
      'userId': userId,
      'shopId': shopId,
      'companyId': companyId,
      'day': day,
      'triggerNum': triggerNum,
    });
    updateOrderId(_docRef.id, status);
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
    String orderId,
    String userId,
    String shopId,
    String companyId,
    String day,
    int triggerNum,
  ) async {
    if (orderId == '') {
      DocumentReference _docRef = await passiveOrderCollection.add({
        'status': status,
        'items': items,
        'price': price,
        'pickUpTime': pickUpTime,
        'username': username,
        'shop': shop,
        'company': company,
        'orderId': orderId,
        'userId': userId,
        'shopId': shopId,
        'companyId': companyId,
        'day': day,
        'triggerNum': triggerNum,
      });
      updateOrderId(_docRef.id, status);
      return _docRef;
    } else {
      return await passiveOrderCollection.doc(orderId).set({
        'status': status,
        'items': items,
        'price': price,
        'pickUpTime': pickUpTime,
        'username': username,
        'shop': shop,
        'company': company,
        'orderId': orderId,
        'userId': userId,
        'shopId': shopId,
        'companyId': companyId,
        'day': day,
        'triggerNum': triggerNum,
      });
    }
  }

  Future createVirtualOrder(
    String status,
    List items,
    int price,
    String pickUpTime,
    String username,
    String place,
    String orderId,
    String userId,
    String day,
    int triggerNum,
  ) async {
    return await virtualOrderCollection.add({
      'status': status,
      'items': items,
      'price': price,
      'pickUpTime': pickUpTime,
      'username': username,
      'place': place,
      'orderId': orderId,
      'userId': userId,
      'day': day,
      'triggerNum': triggerNum,
    });
  }

  // SET ID FOR NEW VIRTUAL ORDER
  Future updateVirtualOrderId(
    String orderId,
  ) async {
    return await virtualOrderCollection.doc(orderId).update({
      'orderId': orderId,
    });
  }

  // SET ID FOR NEW ORDER
  Future updateOrderId(
    String orderId,
    String status,
  ) async {
    if (status == 'ACTIVE' || status == 'PENDING') {
      return await activeOrderCollection.doc(orderId).update({
        'orderId': orderId,
      });
    } else {
      return await passiveOrderCollection.doc(orderId).update({
        'orderId': orderId,
      });
    }
  }

  // UPDATE ORDER STATUS FROM 'ACTIVE' TO 'READY'
  Future updateOrderStatus(
    String orderId,
    String status,
  ) async {
    return await activeOrderCollection.doc(orderId).update({
      'status': status,
    });
  }

  // CHANGE ORDER 'TRIGGER FLAG' TO TRIGGER DIFFERENT EVENTS
  Future triggerOrder(
    String orderId,
    int triggerNum,
  ) async {
    return await activeOrderCollection.doc(orderId).update({
      'triggerNum': triggerNum,
    });
  }

  // GET ORDER LIST FROM DATABASE
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
        orderId: (doc.data() as dynamic)['orderId'],
        userId: (doc.data() as dynamic)['userId'],
        shopId: (doc.data() as dynamic)['shopId'],
        companyId: (doc.data() as dynamic)['companyId'],
        day: (doc.data() as dynamic)['day'],
        triggerNum: (doc.data() as dynamic)['triggerNum'],
      );
    }).toList();
  }

  // GET SPECIFIC ORDER FROM DATABASE
  Order _OrderFromSnapshot(DocumentSnapshot snapshot) {
    return Order(
      status: (snapshot.data() as dynamic)['status'],
      items: (snapshot.data() as dynamic)['items'],
      price: (snapshot.data() as dynamic)['price'],
      pickUpTime: (snapshot.data() as dynamic)['pickUpTime'],
      username: (snapshot.data() as dynamic)['username'],
      shop: (snapshot.data() as dynamic)['shop'],
      company: (snapshot.data() as dynamic)['company'],
      orderId: (snapshot.data() as dynamic)['orderId'],
      userId: (snapshot.data() as dynamic)['userId'],
      shopId: (snapshot.data() as dynamic)['shopId'],
      companyId: (snapshot.data() as dynamic)['companyId'],
      day: (snapshot.data() as dynamic)['day'],
      triggerNum: (snapshot.data() as dynamic)['triggerNum'],
    );
  }

  // GET ACTIVE ORDERS LIST STREAM
  Stream<List<Order>> get activeOrderList {
    return activeOrderCollection.snapshots().map(_OrderListFromSnapshot);
  }

  // GET PASSIVE ORDERS LIST STREAM
  Stream<List<Order>> get passiveOrderList {
    return passiveOrderCollection.snapshots().map(_OrderListFromSnapshot);
  }

  // GET VIRTUAL ORDERS LIST STREAM
  Stream<List<Order>> get virtualOrderList {
    return virtualOrderCollection.snapshots().map(_OrderListFromSnapshot);
  }

  // GET SPECIFIC ORDER DOCUMENT STREAM
  Stream<Order> get order {
    return activeOrderCollection.doc(uid).snapshots().map(_OrderFromSnapshot);
  }
}
