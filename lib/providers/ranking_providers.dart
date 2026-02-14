import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/models/book_model.dart';
import '../core/constants/api_constants.dart';

/// 교환왕 랭킹 - totalExchanges 기준
final topExchangersProvider = FutureProvider<List<UserModel>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection(ApiConstants.usersCollection)
      .where('status', isEqualTo: 'active')
      .orderBy('totalExchanges', descending: true)
      .limit(20)
      .get();
  return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
});

/// 인기 책 랭킹 - wishCount 기준
final popularBooksProvider = FutureProvider<List<BookModel>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection(ApiConstants.booksCollection)
      .where('status', isEqualTo: 'available')
      .orderBy('wishCount', descending: true)
      .limit(20)
      .get();
  return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
});

/// 조회수 높은 책 - viewCount 기준
final mostViewedBooksProvider = FutureProvider<List<BookModel>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection(ApiConstants.booksCollection)
      .where('status', isEqualTo: 'available')
      .orderBy('viewCount', descending: true)
      .limit(20)
      .get();
  return snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList();
});
