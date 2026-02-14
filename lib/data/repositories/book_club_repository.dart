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

  Future<void> updateClub(String clubId, Map<String, dynamic> data) async {
    await _clubsRef.doc(clubId).update(data);
  }

  // --- 그룹 채팅 (서브컬렉션: book_clubs/{clubId}/messages) ---

  CollectionReference<Map<String, dynamic>> _messagesRef(String clubId) =>
      _clubsRef.doc(clubId).collection('messages');

  Stream<List<Map<String, dynamic>>> watchMessages(String clubId) {
    return _messagesRef(clubId)
        .orderBy('createdAt', descending: false)
        .limitToLast(100)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> sendMessage(String clubId, {
    required String senderUid,
    required String senderNickname,
    String? senderProfileImageUrl,
    required String content,
  }) async {
    final now = Timestamp.now();
    await _messagesRef(clubId).add({
      'senderUid': senderUid,
      'senderNickname': senderNickname,
      'senderProfileImageUrl': senderProfileImageUrl,
      'content': content,
      'createdAt': now,
    });
    // 부모 문서에 마지막 메시지 갱신
    await _clubsRef.doc(clubId).update({
      'lastMessage': content,
      'lastMessageAt': now,
    });
  }

  // --- 실시간 모임 정보 ---

  Stream<BookClubModel?> watchClub(String clubId) {
    return _clubsRef.doc(clubId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return BookClubModel.fromFirestore(doc);
    });
  }
}
