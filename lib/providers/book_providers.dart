import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/book_info_repository.dart';
import '../data/models/book_model.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});

final bookInfoRepositoryProvider = Provider<BookInfoRepository>((ref) {
  return BookInfoRepository();
});

/// 홈 피드 - 실시간 스트림 (책 등록 시 즉시 반영)
final availableBooksProvider = StreamProvider.family<List<BookModel>, String?>((ref, genre) {
  return ref.watch(bookRepositoryProvider).watchAvailableBooks(genre: genre);
});

final bookDetailProvider = FutureProvider.family<BookModel?, String>((ref, bookId) async {
  return ref.watch(bookRepositoryProvider).getBook(bookId);
});

/// 내 책장 - 실시간 스트림 (책 등록/삭제/수정 즉시 반영)
final userBooksProvider = StreamProvider.family<List<BookModel>, String>((ref, uid) {
  return ref.watch(bookRepositoryProvider).watchUserBooks(uid);
});

/// 판매 목록 스트림
final saleListingsProvider = StreamProvider.family<List<BookModel>, String?>((ref, genre) {
  return ref.watch(bookRepositoryProvider).watchSaleListings(genre: genre);
});

/// 교환 목록 스트림
final exchangeListingsProvider = StreamProvider.family<List<BookModel>, String?>((ref, genre) {
  return ref.watch(bookRepositoryProvider).watchExchangeListings(genre: genre);
});

final bookSearchProvider = FutureProvider.family<List<BookModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return ref.watch(bookRepositoryProvider).searchBooks(query);
});
