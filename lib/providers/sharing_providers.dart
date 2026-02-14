import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/sharing_repository.dart';
import '../data/models/sharing_request_model.dart';
import 'auth_providers.dart';

final sharingRepositoryProvider = Provider<SharingRepository>((ref) {
  return SharingRepository();
});

final incomingSharingRequestsProvider =
    StreamProvider<List<SharingRequestModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(sharingRepositoryProvider).watchIncomingRequests(user.uid);
});

final sentSharingRequestsProvider =
    StreamProvider<List<SharingRequestModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(sharingRepositoryProvider).watchSentRequests(user.uid);
});
