import 'package:cafe_app/models/article.dart';
import 'package:cafe_app/models/coffee.dart';
import 'package:cafe_app/models/company.dart';
import 'package:cafe_app/models/order.dart';
import 'package:cafe_app/models/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafe_app/models/user.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // USER ---------------------------------------------------------------------------------
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future updateUserData(String name, String surname, String email, String role,
      String spz, String stand) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'surname': surname,
      'email': email,
      'role': role,
      'spz': spz,
      'stand': stand,
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
      spz: (snapshot.data() as dynamic)['spz'],
      stand: (snapshot.data() as dynamic)['stand'],
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
        spz: (doc.data() as dynamic)['spz'],
        stand: (doc.data() as dynamic)['stand'],
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

  Future deleteOrder(String orderId) async {
    return await activeOrderCollection.doc(orderId).delete();
  }

  Future createOrder(
    String state,
    List coffee,
    int price,
    String pickUpTime,
    String username,
    String spz,
    String place,
    String orderId,
    String userId,
  ) async {
    if (state == 'active') {
      return await activeOrderCollection.add({
        'state': state,
        'coffee': coffee,
        'price': price,
        'pickUpTime': pickUpTime,
        'username': username,
        'spz': spz,
        'place': place,
        'orderId': orderId,
        'userId': userId,
      });
    } else {
      return await passiveOrderCollection.doc(orderId).set({
        'state': state,
        'coffee': coffee,
        'price': price,
        'pickUpTime': pickUpTime,
        'username': username,
        'spz': spz,
        'place': place,
        'orderId': orderId,
        'userId': userId,
      });
    }
  }

  // set ID for new order
  Future setOrderId(
    String state,
    List coffee,
    int price,
    String pickUpTime,
    String username,
    String spz,
    String place,
    String orderId,
    String userId,
  ) async {
    if (state == 'active') {
      return await activeOrderCollection.doc(orderId).set({
        'state': state,
        'coffee': coffee,
        'price': price,
        'pickUpTime': pickUpTime,
        'username': username,
        'spz': spz,
        'place': place,
        'orderId': orderId,
        'userId': userId,
      });
    } else {
      return await passiveOrderCollection.doc(orderId).set({
        'state': state,
        'coffee': coffee,
        'price': price,
        'pickUpTime': pickUpTime,
        'username': username,
        'spz': spz,
        'place': place,
        'orderId': orderId,
        'userId': userId,
      });
    }
  }

  // active orders list from snapshot
  List<Order> _OrderListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Order(
        state: (doc.data() as dynamic)['state'],
        coffee: (doc.data() as dynamic)['coffee'],
        price: (doc.data() as dynamic)['price'],
        pickUpTime: (doc.data() as dynamic)['pickUpTime'],
        username: (doc.data() as dynamic)['username'],
        spz: (doc.data() as dynamic)['spz'],
        place: (doc.data() as dynamic)['place'],
        orderId: (doc.data() as dynamic)['orderId'],
        userId: (doc.data() as dynamic)['userId'],
      );
    }).toList();
  }

  // get active orders list stream
  Stream<List<Order>> get activeOrderList {
    return activeOrderCollection.snapshots().map(_OrderListFromSnapshot);
  }

  // get passive orders list stream
  Stream<List<Order>> get passiveOrderList {
    return passiveOrderCollection.snapshots().map(_OrderListFromSnapshot);
  }

  // END ORDER ----------------------------------------------------------------------------

  // ARTICLE ------------------------------------------------------------------------------
  final CollectionReference articleCollection =
      FirebaseFirestore.instance.collection('help_articles');

  // articles from snapshot
  List<Article> _articlesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Article(
        title: (doc.data() as dynamic)['title'],
        body: (doc.data() as dynamic)['body'],
      );
    }).toList();
  }

  // get article doc stream
  Stream<List<Article>> get articleList {
    return articleCollection.snapshots().map(_articlesFromSnapshot);
  }

  // END ARTICLE --------------------------------------------------------------------------

  // COFFEE -------------------------------------------------------------------------------
  final CollectionReference coffeeCollection =
      FirebaseFirestore.instance.collection('coffees');

  Future updateCoffeeData(String uid, String name, int price, int count) async {
    return await coffeeCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'price': price,
      'count': count,
    });
  }

  // coffees from snapshot
  List<Coffee> _coffeesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Coffee(
        name: (doc.data() as dynamic)['name'],
        price: (doc.data() as dynamic)['price'],
        count: (doc.data() as dynamic)['count'],
        uid: (doc.data() as dynamic)['uid'],
      );
    }).toList();
  }

  // get coffee doc stream
  Stream<List<Coffee>> get coffeeList {
    return coffeeCollection.snapshots().map(_coffeesFromSnapshot);
  }

  // END COFFEE ---------------------------------------------------------------------------

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
}
