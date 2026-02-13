import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/exchange_repository.dart';
import '../data/models/exchange_request_model.dart';
import '../data/models/match_model.dart';
import 'auth_providers.dart';

final exchangeRepositoryProvider = Provider<ExchangeRepository>((ref) {
  return ExchangeRepository();
});

final incomingRequestsProvider = FutureProvider<List<ExchangeRequestModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(exchangeRepositoryProvider).getIncomingRequests(user.uid);
});

final sentRequestsProvider = FutureProvider<List<ExchangeRequestModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(exchangeRepositoryProvider).getSentRequests(user.uid);
});

final userMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(exchangeRepositoryProvider).getUserMatches(user.uid);
});
