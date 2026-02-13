import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String matchId;
  final String reviewerUid;
  final String revieweeUid;
  final double rating;
  final double bookConditionAccuracy;
  final double responseSpeed;
  final double manner;
  final String? comment;
  final List<String> tags;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.matchId,
    required this.reviewerUid,
    required this.revieweeUid,
    required this.rating,
    required this.bookConditionAccuracy,
    required this.responseSpeed,
    required this.manner,
    this.comment,
    this.tags = const [],
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      matchId: data['matchId'] ?? '',
      reviewerUid: data['reviewerUid'] ?? '',
      revieweeUid: data['revieweeUid'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      bookConditionAccuracy: (data['bookConditionAccuracy'] ?? 0).toDouble(),
      responseSpeed: (data['responseSpeed'] ?? 0).toDouble(),
      manner: (data['manner'] ?? 0).toDouble(),
      comment: data['comment'],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'matchId': matchId,
      'reviewerUid': reviewerUid,
      'revieweeUid': revieweeUid,
      'rating': rating,
      'bookConditionAccuracy': bookConditionAccuracy,
      'responseSpeed': responseSpeed,
      'manner': manner,
      'comment': comment,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
