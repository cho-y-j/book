import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/admin_repository.dart';
import '../data/models/user_model.dart';
import '../data/models/book_model.dart';
import 'user_providers.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProfileProvider).valueOrNull;
  return user?.role == 'admin';
});

final isDealerProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProfileProvider).valueOrNull;
  return user?.role == 'dealer' && user?.dealerStatus == 'approved';
});

final adminStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(adminRepositoryProvider).getStats();
});

final allUsersProvider = FutureProvider.family<List<UserModel>, String?>((ref, role) async {
  return ref.watch(adminRepositoryProvider).getAllUsers(role: role);
});

final allBooksAdminProvider = FutureProvider.family<List<BookModel>, String?>((ref, status) async {
  return ref.watch(adminRepositoryProvider).getAllBooks(status: status);
});

final pendingDealerRequestsProvider = FutureProvider<List<UserModel>>((ref) async {
  return ref.watch(adminRepositoryProvider).getPendingDealerRequests();
});

final pendingReportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(adminRepositoryProvider).getPendingReports();
});

final adminUserDetailProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  return ref.watch(userRepositoryProvider).getUser(userId);
});
