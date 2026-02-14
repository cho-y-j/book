import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_club_model.dart';
import '../../core/constants/api_constants.dart';

class BookClubRepository {
  final FirebaseFirestore _firestore;

  BookClubRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clubsRef =>
      _firestore.collection(ApiConstants.bookClubsCollection);

  Future<String> createBookClub(BookClubModel club) async {
    final doc = await _clubsRef.add(club.toFirestore());
    return doc.id;
  }

  Future<List<BookClubModel>> getBookClubs({int limit = 20}) async {
    final snapshot = await _clubsRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => BookClubModel.fromFirestore(doc)).toList();
  }

  Future<BookClubModel?> getBookClub(String clubId) async {
    final doc = await _clubsRef.doc(clubId).get();
    if (!doc.exists) return null;
    return BookClubModel.fromFirestore(doc);
  }

  Future<void> joinBookClub(String clubId, String uid) async {
    await _clubsRef.doc(clubId).update({
      'memberUids': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> leaveBookClub(String clubId, String uid) async {
    await _clubsRef.doc(clubId).update({
      'memberUids': FieldValue.arrayRemove([uid]),
    });
  }

  Future<void> deleteBookClub(String clubId) async {
    await _clubsRef.doc(clubId).delete();
  }
}
