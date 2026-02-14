import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/purchase_repository.dart';
import '../data/models/purchase_request_model.dart';
import 'auth_providers.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepository();
});

final incomingPurchaseRequestsProvider =
    StreamProvider<List<PurchaseRequestModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(purchaseRepositoryProvider).watchIncomingRequests(user.uid);
});

final sentPurchaseRequestsProvider =
    StreamProvider<List<PurchaseRequestModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(purchaseRepositoryProvider).watchSentRequests(user.uid);
});
