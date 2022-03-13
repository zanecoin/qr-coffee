import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_coffee/models/worker.dart';

class WorkerDatabase {
  final String? userID;
  WorkerDatabase({this.userID});

  final CollectionReference workerCollection = FirebaseFirestore.instance.collection('workers');

  Future updateWorkerData(String companyID) async {
    return await workerCollection.doc(userID).set({'companyID': companyID});
  }

  Worker _workerDataFromSnapshot(DocumentSnapshot snapshot) {
    return Worker(
      userID: userID!,
      companyID: (snapshot.data() as dynamic)['companyID'],
    );
  }

  List<Worker> _workerDataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Worker(
        userID: userID!,
        companyID: (doc.data() as dynamic)['companyID'],
      );
    }).toList();
  }

  // Get admin document stream.
  Stream<Worker> get worker {
    return workerCollection.doc(userID).snapshots().map(_workerDataFromSnapshot);
  }

  // Get admin list stream.
  Stream<List<Worker>> get workerList {
    return workerCollection.snapshots().map(_workerDataListFromSnapshot);
  }
}
