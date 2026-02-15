import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(ApiConstants.usersCollection);

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> createUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toFirestore());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersRef.doc(uid).update(data);
  }

  Future<void> updateTemperature(String uid, double newTemp) async {
    await _usersRef.doc(uid).update({'bookTemperature': newTemp});
  }

  Future<void> incrementExchangeCount(String uid) async {
    await _usersRef.doc(uid).update({
      'totalExchanges': FieldValue.increment(1),
    });
  }

  Future<void> addBadge(String uid, String badge) async {
    await _usersRef.doc(uid).update({
      'badges': FieldValue.arrayUnion([badge]),
    });
  }

  Future<void> updatePoints(String uid, int points) async {
    await _usersRef.doc(uid).update({
      'points': FieldValue.increment(points),
    });
  }

  Stream<UserModel?> watchUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Future<void> updateHometown(
    String uid,
    String hometown,
    String region,
    String subRegion,
  ) async {
    await _usersRef.doc(uid).update({
      'hometown': hometown,
      'hometownRegion': region,
      'hometownSubRegion': subRegion,
    });
  }
}
