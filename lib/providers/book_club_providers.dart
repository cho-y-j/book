import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/book_club_repository.dart';
import '../data/models/book_club_model.dart';

final bookClubRepositoryProvider = Provider<BookClubRepository>((ref) {
  return BookClubRepository();
});

final bookClubsProvider = FutureProvider<List<BookClubModel>>((ref) async {
  return ref.watch(bookClubRepositoryProvider).getBookClubs();
});

final bookClubDetailProvider = FutureProvider.family<BookClubModel?, String>((ref, clubId) async {
  return ref.watch(bookClubRepositoryProvider).getBookClub(clubId);
});
