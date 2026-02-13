import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../../core/constants/api_constants.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reviewsRef =>
      _firestore.collection(ApiConstants.reviewsCollection);

  Future<void> createReview(ReviewModel review) async {
    await _reviewsRef.add(review.toFirestore());
  }

  Future<List<ReviewModel>> getUserReviews(String uid) async {
    final snapshot = await _reviewsRef
        .where('revieweeUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((d) => ReviewModel.fromFirestore(d)).toList();
  }

  Future<double> getAverageRating(String uid) async {
    final reviews = await getUserReviews(uid);
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (acc, r) => acc + r.rating);
    return total / reviews.length;
  }
}
