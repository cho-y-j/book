import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../../core/constants/api_constants.dart';

class BookRepository {
  final FirebaseFirestore _firestore;

  BookRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _booksRef =>
      _firestore.collection(ApiConstants.booksCollection);

  Future<String> createBook(BookModel book) async {
    final doc = await _booksRef.add(book.toFirestore());
    return doc.id;
  }

  Future<BookModel?> getBook(String bookId) async {
    final doc = await _booksRef.doc(bookId).get();
    if (!doc.exists) return null;
    return BookModel.fromFirestore(doc);
  }

  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    await _booksRef.doc(bookId).update(data);
  }

  Future<void> deleteBook(String bookId) async {
    await _booksRef.doc(bookId).delete();
  }

  /// 홈 피드 - 지역 기반 교환 가능한 책
  Future<List<BookModel>> getAvailableBooks({
    String? genre,
    String? location,
    int limit = 20,
    DocumentSnapshot? lastDoc,
  }) async {
    Query<Map<String, dynamic>> query = _booksRef
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (genre != null && genre != '전체') {
      query = query.where('genre', isEqualTo: genre);
    }

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
  }

  /// 내 책장
  Future<List<BookModel>> getUserBooks(String uid, {String? status}) async {
    Query<Map<String, dynamic>> query = _booksRef
        .where('ownerUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
  }

  /// 검색
  Future<List<BookModel>> searchBooks(String query) async {
    final snapshot = await _booksRef
        .where('status', isEqualTo: 'available')
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(50)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
  }

  /// 조회수 증가
  Future<void> incrementViewCount(String bookId) async {
    await _booksRef.doc(bookId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  /// 끌어올리기 (updatedAt 갱신 → 최신으로 올라감)
  Future<void> bumpBook(String bookId) async {
    await _booksRef.doc(bookId).update({
      'updatedAt': Timestamp.now(),
    });
  }

  /// 가리기/숨기기 토글
  Future<void> toggleHideBook(String bookId, bool hide) async {
    await _booksRef.doc(bookId).update({
      'status': hide ? 'hidden' : 'available',
      'updatedAt': Timestamp.now(),
    });
  }

  /// 판매 목록 실시간 스트림
  Stream<List<BookModel>> watchSaleListings({String? genre, int limit = 20}) {
    Query<Map<String, dynamic>> query = _booksRef
        .where('status', isEqualTo: 'available')
        .where('listingType', whereIn: ['sale', 'both'])
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (genre != null && genre != '전체') {
      query = query.where('genre', isEqualTo: genre);
    }

    return query.snapshots().map(
      (snap) => snap.docs.map((doc) => BookModel.fromFirestore(doc)).toList(),
    );
  }

  /// 교환 목록 실시간 스트림
  Stream<List<BookModel>> watchExchangeListings({String? genre, int limit = 20}) {
    Query<Map<String, dynamic>> query = _booksRef
        .where('status', isEqualTo: 'available')
        .where('listingType', whereIn: ['exchange', 'both'])
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (genre != null && genre != '전체') {
      query = query.where('genre', isEqualTo: genre);
    }

    return query.snapshots().map(
      (snap) => snap.docs.map((doc) => BookModel.fromFirestore(doc)).toList(),
    );
  }

  /// 나눔 목록 실시간 스트림
  Stream<List<BookModel>> watchSharingListings({String? genre, int limit = 20}) {
    Query<Map<String, dynamic>> query = _booksRef
        .where('status', isEqualTo: 'available')
        .where('listingType', isEqualTo: 'sharing')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (genre != null && genre != '전체') {
      query = query.where('genre', isEqualTo: genre);
    }

    return query.snapshots().map(
      (snap) => snap.docs.map((doc) => BookModel.fromFirestore(doc)).toList(),
    );
  }

  /// 기증 목록 실시간 스트림
  Stream<List<BookModel>> watchDonationListings({String? genre, int limit = 20}) {
    Query<Map<String, dynamic>> query = _booksRef
        .where('status', isEqualTo: 'available')
        .where('listingType', isEqualTo: 'donation')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (genre != null && genre != '전체') {
      query = query.where('genre', isEqualTo: genre);
    }

    return query.snapshots().map(
      (snap) => snap.docs.map((doc) => BookModel.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<BookModel>> watchUserBooks(String uid) {
    return _booksRef
        .where('ownerUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => BookModel.fromFirestore(d)).toList());
  }

  /// 홈 피드 실시간 스트림
  Stream<List<BookModel>> watchAvailableBooks({
    String? genre,
    int limit = 20,
  }) {
    Query<Map<String, dynamic>> query = _booksRef
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (genre != null && genre != '전체') {
      query = query.where('genre', isEqualTo: genre);
    }

    return query.snapshots().map(
      (snap) => snap.docs.map((doc) => BookModel.fromFirestore(doc)).toList(),
    );
  }
}
