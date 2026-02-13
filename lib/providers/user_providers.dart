import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';
import 'auth_providers.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(user.uid);
});
