import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String id;
  final String userUid;
  final String bookInfoId;
  final String title;
  final String author;
  final String? coverImageUrl;
  final DateTime createdAt;
  final bool isNotified;

  const WishlistModel({
    required this.id,
    required this.userUid,
    required this.bookInfoId,
    required this.title,
    this.author = '',
    this.coverImageUrl,
    required this.createdAt,
    this.isNotified = false,
  });

  factory WishlistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WishlistModel(
      id: doc.id,
      userUid: data['userUid'] ?? '',
      bookInfoId: data['bookInfoId'] ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      coverImageUrl: data['coverImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isNotified: data['isNotified'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userUid': userUid,
      'bookInfoId': bookInfoId,
      'title': title,
      'author': author,
      'coverImageUrl': coverImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isNotified': isNotified,
    };
  }
}
