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

final availableBooksProvider = FutureProvider.family<List<BookModel>, String?>((ref, genre) async {
  return ref.watch(bookRepositoryProvider).getAvailableBooks(genre: genre);
});

final bookDetailProvider = FutureProvider.family<BookModel?, String>((ref, bookId) async {
  return ref.watch(bookRepositoryProvider).getBook(bookId);
});

final userBooksProvider = FutureProvider.family<List<BookModel>, String>((ref, uid) async {
  return ref.watch(bookRepositoryProvider).getUserBooks(uid);
});

final bookSearchProvider = FutureProvider.family<List<BookModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return ref.watch(bookRepositoryProvider).searchBooks(query);
});
