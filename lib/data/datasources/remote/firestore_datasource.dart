import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatasource {
  final FirebaseFirestore _firestore;
  FirestoreDatasource({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String path) => _firestore.collection(path);

  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(String collection, String docId) =>
      _firestore.collection(collection).doc(docId).get();

  Future<DocumentReference<Map<String, dynamic>>> addDoc(String collection, Map<String, dynamic> data) =>
      _firestore.collection(collection).add(data);

  Future<void> setDoc(String collection, String docId, Map<String, dynamic> data, {bool merge = false}) =>
      _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: merge));

  Future<void> updateDoc(String collection, String docId, Map<String, dynamic> data) =>
      _firestore.collection(collection).doc(docId).update(data);

  Future<void> deleteDoc(String collection, String docId) =>
      _firestore.collection(collection).doc(docId).delete();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(String collection, {List<List<dynamic>>? where, String? orderBy, bool descending = false, int? limit}) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    if (where != null) { for (final w in where) { query = query.where(w[0] as String, isEqualTo: w.length > 1 ? w[1] : null); } }
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }

  WriteBatch batch() => _firestore.batch();
}
