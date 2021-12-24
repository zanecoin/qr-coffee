import 'package:qr_coffee/models/article.dart';
import 'package:qr_coffee/models/item.dart';
import 'package:qr_coffee/models/company.dart';
import 'package:qr_coffee/models/credit_card.dart';
import 'package:qr_coffee/models/order.dart';
import 'package:qr_coffee/models/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_coffee/models/user.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // USER ---------------------------------------------------------------------------------
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name, String surname, String email, String role,
      int tokens, String stand, int numOrders) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'surname': surname,
      'email': email,
      'role': role,
      'tokens': tokens,
      'stand': stand,
      'numOrders': numOrders,
    });
  }

  // userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid!,
      name: (snapshot.data() as dynamic)['name'],
      surname: (snapshot.data() as dynamic)['surname'],
      email: (snapshot.data() as dynamic)['email'],
      role: (snapshot.data() as dynamic)['role'],
      tokens: (snapshot.data() as dynamic)['tokens'],
      stand: (snapshot.data() as dynamic)['stand'],
      numOrders: (snapshot.data() as dynamic)['numOrders'],
    );
  }

  // get user doc stream
  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  // userDataList from snapshot
  List<UserData> _userDataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserData(
        uid: uid!,
        name: (doc.data() as dynamic)['name'],
        surname: (doc.data() as dynamic)['surname'],
        email: (doc.data() as dynamic)['email'],
        role: (doc.data() as dynamic)['role'],
        tokens: (doc.data() as dynamic)['tokens'],
        stand: (doc.data() as dynamic)['stand'],
        numOrders: (doc.data() as dynamic)['numOrders'],
      );
    }).toList();
  }

  // get user doc list stream
  Stream<List<UserData>> get userDataList {
    return userCollection.snapshots().map(_userDataListFromSnapshot);
  }

  // END USER -----------------------------------------------------------------------------

  // ORDER --------------------------------------------------------------------------------
  final CollectionReference activeOrderCollection =
      FirebaseFirestore.instance.collection('active_orders');
  final CollectionReference passiveOrderCollection =
      FirebaseFirestore.instance.collection('passive_orders');
  final CollectionReference virtualOrderCollection =
      FirebaseFirestore.instance.collection('virtual_orders');

  Future deleteActiveOrder(String orderId) async {
    return await activeOrderCollection.doc(orderId).delete();
  }

  Future createActiveOrder(
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
    return await activeOrderCollection.add({
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

  Future createPassiveOrder(
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
    return await passiveOrderCollection.doc(orderId).set({
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
        place: (doc.data() as dynamic)['place'],
        orderId: (doc.data() as dynamic)['orderId'],
        userId: (doc.data() as dynamic)['userId'],
        day: (doc.data() as dynamic)['day'],
        triggerNum: (doc.data() as dynamic)['triggerNum'],
      );
    }).toList();
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
    return passiveOrderCollection.snapshots().map(_OrderListFromSnapshot);
  }

  // GET SPECIFIC ORDER FROM DATABASE
  Order _OrderFromSnapshot(DocumentSnapshot snapshot) {
    return Order(
      status: (snapshot.data() as dynamic)['status'],
      items: (snapshot.data() as dynamic)['items'],
      price: (snapshot.data() as dynamic)['price'],
      pickUpTime: (snapshot.data() as dynamic)['pickUpTime'],
      username: (snapshot.data() as dynamic)['username'],
      place: (snapshot.data() as dynamic)['place'],
      orderId: (snapshot.data() as dynamic)['orderId'],
      userId: (snapshot.data() as dynamic)['userId'],
      day: (snapshot.data() as dynamic)['day'],
      triggerNum: (snapshot.data() as dynamic)['triggerNum'],
    );
  }

  // GET SPECIFIC ORDER DOCUMENT STREAM
  Stream<Order> get order {
    return activeOrderCollection.doc(uid).snapshots().map(_OrderFromSnapshot);
  }

  // END ORDER ----------------------------------------------------------------------------

  // ITEMS -------------------------------------------------------------------------------
  final CollectionReference itemCollection =
      FirebaseFirestore.instance.collection('items');

  Future updateCoffeeData(String uid, String name, String type, int price,
      int count, String picture) async {
    return await itemCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'price': price,
      'count': count,
      'type': type,
      'picture': picture
    });
  }

  // items from snapshot
  List<Item> _itemsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Item(
        name: (doc.data() as dynamic)['name'],
        price: (doc.data() as dynamic)['price'],
        type: (doc.data() as dynamic)['type'],
        count: (doc.data() as dynamic)['count'],
        uid: (doc.data() as dynamic)['uid'],
        picture: (doc.data() as dynamic)['picture'],
      );
    }).toList();
  }

  // get item doc stream
  Stream<List<Item>> get coffeeList {
    return itemCollection.snapshots().map(_itemsFromSnapshot);
  }

  // END ITEM ---------------------------------------------------------------------------

  // PLACE -------------------------------------------------------------------------------
  final CollectionReference placeCollection =
      FirebaseFirestore.instance.collection('coffee_stands');

  Future updatePlaceData(String address, String coordinate, bool active) async {
    return await placeCollection.doc(uid).set({
      'uid': uid,
      'address': address,
      'coordinate': coordinate,
      'active': active,
    });
  }

  // places from snapshot
  List<Place> _placesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Place(
        uid: (doc.data() as dynamic)['uid'],
        address: (doc.data() as dynamic)['address'],
        coordinate: (doc.data() as dynamic)['coordinate'],
        active: (doc.data() as dynamic)['active'],
      );
    }).toList();
  }

  // get place doc stream
  Stream<List<Place>> get placeList {
    return placeCollection.snapshots().map(_placesFromSnapshot);
  }

  // END PLACE ---------------------------------------------------------------------------

  // COMPANY ------------------------------------------------------------------------------
  final CollectionReference companyCollection =
      FirebaseFirestore.instance.collection('company_info');

  // company from snapshot
  Company _companyFromSnapshot(DocumentSnapshot snapshot) {
    return Company(
      name: (snapshot.data() as dynamic)['name'],
      phone: (snapshot.data() as dynamic)['phone'],
      email: (snapshot.data() as dynamic)['email'],
      headquarters: (snapshot.data() as dynamic)['headquarters'],
    );
  }

  // get company doc stream
  Stream<Company> get company {
    return companyCollection
        .doc('info_uid')
        .snapshots()
        .map(_companyFromSnapshot);
  }
  // END COMPANY --------------------------------------------------------------------------

  // CREDIT CARD --------------------------------------------------------------------------

  // // add new card
  // Future<DocumentReference> updateCards(String cardNumber, String expiryDate,
  //     String cardHolderName, String cvvCode) async {
  //   return await userCollection.doc(uid).collection('cards').add({
  //     'uid': '',
  //     'cardNumber': cardNumber,
  //     'expiryDate': expiryDate,
  //     'cardHolderName': cardHolderName,
  //     'cvvCode': cvvCode,
  //   });
  // }

  // deleteCard(String? cardID) {
  //   userCollection.doc(uid).collection('cards').doc(cardID).delete();
  // }

  // // add card id
  // Future setCardID(String cardID, String cardNumber, String expiryDate,
  //     String cardHolderName, String cvvCode) async {
  //   return await userCollection.doc(uid).collection('cards').doc(cardID).set({
  //     'uid': cardID,
  //     'cardNumber': cardNumber,
  //     'expiryDate': expiryDate,
  //     'cardHolderName': cardHolderName,
  //     'cvvCode': cvvCode,
  //   });
  // }

  // // card List from snapshot
  // List<UserCard> _cardListFromSnapshot(QuerySnapshot snapshot) {
  //   return snapshot.docs.map((doc) {
  //     return UserCard(
  //       uid: (doc.data() as dynamic)['uid'],
  //       cardNumber: (doc.data() as dynamic)['cardNumber'],
  //       expiryDate: (doc.data() as dynamic)['expiryDate'],
  //       cardHolderName: (doc.data() as dynamic)['cardHolderName'],
  //       cvvCode: (doc.data() as dynamic)['cvvCode'],
  //     );
  //   }).toList();
  // }

  // // get card doc list stream
  // Stream<List<UserCard>> get cardList {
  //   CollectionReference cardCollection =
  //       userCollection.doc(uid).collection('cards');
  //   return cardCollection.snapshots().map(_cardListFromSnapshot);
  // }

  // END CREDIT CARD ----------------------------------------------------------------------

  // ARTICLE ------------------------------------------------------------------------------
  // final CollectionReference articleCollection =
  //     FirebaseFirestore.instance.collection('help_articles');

  // // articles from snapshot
  // List<Article> _articlesFromSnapshot(QuerySnapshot snapshot) {
  //   return snapshot.docs.map((doc) {
  //     return Article(
  //       title: (doc.data() as dynamic)['title'],
  //       body: (doc.data() as dynamic)['body'],
  //     );
  //   }).toList();
  // }

  // // get article doc stream
  // Stream<List<Article>> get articleList {
  //   return articleCollection.snapshots().map(_articlesFromSnapshot);
  // }

  // END ARTICLE --------------------------------------------------------------------------
}
