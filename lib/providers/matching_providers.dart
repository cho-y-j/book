import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/book_model.dart';
import '../data/models/organization_model.dart';
import 'auth_providers.dart';
import 'book_providers.dart';
import 'donation_providers.dart';

class BookMatchRecommendation {
  final BookModel book;
  final OrganizationModel organization;
  final String matchReason;

  const BookMatchRecommendation({
    required this.book,
    required this.organization,
    required this.matchReason,
  });
}

/// 유저의 책 장르 ↔ 기관 wishBooks 클라이언트사이드 매칭
final wishBookMatchesProvider =
    FutureProvider<List<BookMatchRecommendation>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final orgs = await ref.watch(organizationsProvider.future);
  final orgsWithWish = orgs.where((o) => o.wishBooks.isNotEmpty).toList();
  if (orgsWithWish.isEmpty) return [];

  final bookRepo = ref.watch(bookRepositoryProvider);
  final myBooks = await bookRepo.getUserBooks(user.uid);
  final availableBooks =
      myBooks.where((b) => b.status == 'available').toList();
  if (availableBooks.isEmpty) return [];

  final matches = <BookMatchRecommendation>[];
  for (final book in availableBooks) {
    final bookGenre = book.genre;
    for (final org in orgsWithWish) {
      if (org.wishBooks.contains(bookGenre)) {
        matches.add(BookMatchRecommendation(
          book: book,
          organization: org,
          matchReason: '${org.name}에서 "$bookGenre" 장르를 희망합니다',
        ));
      }
    }
  }
  return matches;
});
