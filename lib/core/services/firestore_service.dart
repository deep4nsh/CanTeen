import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> createDocument(String path, Map<String, dynamic> data) {
    return _db.doc(path).set(data);
  }

  Stream<DocumentSnapshot> streamDocument(String path) {
    return _db.doc(path).snapshots();
  }

  Stream<QuerySnapshot> streamCollection(String path) {
    return _db.collection(path).snapshots();
  }
}
