import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/book_club_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/book_club_model.dart';
import '../data/models/user_model.dart';

final bookClubRepositoryProvider = Provider<BookClubRepository>((ref) {
  return BookClubRepository();
});

final bookClubsProvider = FutureProvider<List<BookClubModel>>((ref) async {
  return ref.watch(bookClubRepositoryProvider).getBookClubs();
});

final bookClubDetailProvider = FutureProvider.family<BookClubModel?, String>((ref, clubId) async {
  return ref.watch(bookClubRepositoryProvider).getBookClub(clubId);
});

/// 실시간 모임 정보 스트림
final bookClubStreamProvider = StreamProvider.family<BookClubModel?, String>((ref, clubId) {
  return ref.watch(bookClubRepositoryProvider).watchClub(clubId);
});

/// 실시간 그룹 채팅 메시지
final clubMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, clubId) {
  return ref.watch(bookClubRepositoryProvider).watchMessages(clubId);
});

/// 멤버 목록 (실제 UserModel)
final clubMembersProvider = FutureProvider.family<List<UserModel>, List<String>>((ref, memberUids) async {
  final userRepo = UserRepository();
  final futures = memberUids.map((uid) => userRepo.getUser(uid));
  final results = await Future.wait(futures);
  return results.whereType<UserModel>().toList();
});
