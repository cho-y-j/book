import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/review_repository.dart';
import '../data/models/review_model.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

final receivedReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, uid) async {
  return ref.watch(reviewRepositoryProvider).getUserReviews(uid);
});
