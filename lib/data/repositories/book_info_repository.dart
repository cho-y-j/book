import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_info_model.dart';
import '../../core/constants/api_constants.dart';

class BookInfoRepository {
  final FirebaseFirestore _firestore;

  BookInfoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookInfoRef =>
      _firestore.collection(ApiConstants.bookInfoCollection);

  Future<BookInfoModel?> getByIsbn(String isbn) async {
    final snapshot = await _bookInfoRef
        .where('isbn', isEqualTo: isbn)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return BookInfoModel.fromFirestore(snapshot.docs.first);
  }

  Future<BookInfoModel?> getById(String id) async {
    final doc = await _bookInfoRef.doc(id).get();
    if (!doc.exists) return null;
    return BookInfoModel.fromFirestore(doc);
  }

  Future<String> create(BookInfoModel bookInfo) async {
    final doc = await _bookInfoRef.add(bookInfo.toFirestore());
    return doc.id;
  }

  Future<void> incrementExchangeCount(String id) async {
    await _bookInfoRef.doc(id).update({
      'exchangeCount': FieldValue.increment(1),
    });
  }

  Future<void> incrementWishlistCount(String id) async {
    await _bookInfoRef.doc(id).update({
      'wishlistCount': FieldValue.increment(1),
    });
  }

  Future<List<BookInfoModel>> search(String query) async {
    final snapshot = await _bookInfoRef
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(20)
        .get();
    return snapshot.docs.map((d) => BookInfoModel.fromFirestore(d)).toList();
  }

  /// 인기 책 TOP N
  Future<List<BookInfoModel>> getPopularBooks({int limit = 20}) async {
    final snapshot = await _bookInfoRef
        .orderBy('exchangeCount', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((d) => BookInfoModel.fromFirestore(d)).toList();
  }
}
