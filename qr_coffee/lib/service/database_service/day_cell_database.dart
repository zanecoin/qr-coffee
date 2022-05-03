import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_coffee/models/dayCell.dart';

class DayCellDatabase {
  final String companyID;
  DayCellDatabase({required this.companyID});

  CollectionReference _getPassiveOrderCollection() {
    return FirebaseFirestore.instance
        .collection('companies')
        .doc(companyID)
        .collection('passive_orders');
  }

  CollectionReference _getVirtualOrderCollection() {
    return FirebaseFirestore.instance
        .collection('companies')
        .doc(companyID)
        .collection('virtual_orders');
  }

  Future createVirtualCell(int numOfOrders, int totalIncome, Map<dynamic, dynamic> items,
      Map<dynamic, dynamic> states, String date) async {
    return await _getVirtualOrderCollection().doc(date).set({
      'lastUpdated': '',
      'numOfOrders': numOfOrders,
      'totalIncome': totalIncome,
      'items': items,
      'states': states,
    });
  }

  // Get specific cell from database.
  DayCell _cellFromSnapshot(DocumentSnapshot snapshot) {
    var timestamp = (snapshot.data() as dynamic)['lastUpdated'];
    var date = timestamp.toDate();
    DayCell cell = DayCell(
      date: snapshot.id,
      lastUpdated: DateFormat('HH:mm').format(date),
      numOfOrders: (snapshot.data() as dynamic)['numOfOrders'] ?? 0,
      totalIncome: (snapshot.data() as dynamic)['totalIncome'] ?? 0,
      items: (snapshot.data() as dynamic)['items'] ?? Map(),
      states: (snapshot.data() as dynamic)['states'] ?? Map(),
    );
    return cell;
  }

  // Get normal cell list from database.
  List<DayCell> _normalCellsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return DayCell(
        date: doc.id,
        lastUpdated: '',
        numOfOrders: (doc.data() as dynamic)['numOfOrders'] ?? 0,
        totalIncome: (doc.data() as dynamic)['totalIncome'] ?? 0,
        items: (doc.data() as dynamic)['items'] ?? Map(),
        states: (doc.data() as dynamic)['states'] ?? Map(),
      );
    }).toList();
  }

  // Get virtual cell list from database.
  List<DayCell> _virtualCellsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return DayCell(
        date: doc.id,
        lastUpdated: '',
        numOfOrders: (doc.data() as dynamic)['numOfOrders'] ?? 0,
        totalIncome: (doc.data() as dynamic)['totalIncome'] ?? 0,
        items: (doc.data() as dynamic)['items'] ?? Map(),
        states: (doc.data() as dynamic)['states'] ?? Map(),
      );
    }).toList();
  }

  // Get specific cell stream.
  Stream<DayCell> get cell {
    String date = DateFormat('yyyy_MM_dd').format(DateTime.now());
    return _getPassiveOrderCollection().doc(date).snapshots().map(_cellFromSnapshot);
  }

  // Get virtual cell list stream.
  Stream<List<DayCell>> get normalCells {
    print(_getPassiveOrderCollection());
    return _getPassiveOrderCollection().snapshots().map(_normalCellsFromSnapshot);
  }

  // Get virtual cell list stream.
  Stream<List<DayCell>> get virtualCells {
    return _getVirtualOrderCollection().snapshots().map(_virtualCellsFromSnapshot);
  }
}
