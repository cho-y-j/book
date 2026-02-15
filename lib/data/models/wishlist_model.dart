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
  // Alert preferences
  final bool alertEnabled;
  final List<String> preferredConditions;
  final List<String> preferredListingTypes;
  final String? alertNote;
  final String? searchKeyword; // 검색어 기반 위시리스트용

  const WishlistModel({
    required this.id,
    required this.userUid,
    required this.bookInfoId,
    required this.title,
    this.author = '',
    this.coverImageUrl,
    required this.createdAt,
    this.isNotified = false,
    this.alertEnabled = false,
    this.preferredConditions = const [],
    this.preferredListingTypes = const [],
    this.alertNote,
    this.searchKeyword,
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
      alertEnabled: data['alertEnabled'] ?? false,
      preferredConditions: List<String>.from(data['preferredConditions'] ?? []),
      preferredListingTypes: List<String>.from(data['preferredListingTypes'] ?? []),
      alertNote: data['alertNote'],
      searchKeyword: data['searchKeyword'],
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
      'alertEnabled': alertEnabled,
      'preferredConditions': preferredConditions,
      'preferredListingTypes': preferredListingTypes,
      if (alertNote != null) 'alertNote': alertNote,
      if (searchKeyword != null) 'searchKeyword': searchKeyword,
    };
  }

  WishlistModel copyWith({
    bool? isNotified,
    bool? alertEnabled,
    List<String>? preferredConditions,
    List<String>? preferredListingTypes,
    String? alertNote,
    String? searchKeyword,
  }) {
    return WishlistModel(
      id: id,
      userUid: userUid,
      bookInfoId: bookInfoId,
      title: title,
      author: author,
      coverImageUrl: coverImageUrl,
      createdAt: createdAt,
      isNotified: isNotified ?? this.isNotified,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      preferredConditions: preferredConditions ?? this.preferredConditions,
      preferredListingTypes: preferredListingTypes ?? this.preferredListingTypes,
      alertNote: alertNote ?? this.alertNote,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }

  /// 이 위시리스트가 주어진 책 제목과 매칭되는지 확인
  bool matchesBook(String bookTitle, String bookInfoId) {
    // 1. ISBN 정확히 일치
    if (this.bookInfoId.isNotEmpty && this.bookInfoId == bookInfoId) return true;
    // 2. 검색어 키워드 매칭 (제목에 포함)
    final keyword = searchKeyword ?? title;
    if (keyword.isNotEmpty && bookTitle.toLowerCase().contains(keyword.toLowerCase())) return true;
    return false;
  }
}
