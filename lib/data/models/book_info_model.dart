import 'package:cloud_firestore/cloud_firestore.dart';

class BookInfoModel {
  final String id;
  final String? isbn;
  final String title;
  final String author;
  final String? publisher;
  final String? publishDate;
  final String? coverImageUrl;
  final String? description;
  final String genre;
  final String? subGenre;
  final int pageCount;
  final String source; // 'api' | 'user_contributed'
  final String? contributedByUid;
  final int exchangeCount;
  final int wishlistCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookInfoModel({
    required this.id,
    this.isbn,
    required this.title,
    required this.author,
    this.publisher,
    this.publishDate,
    this.coverImageUrl,
    this.description,
    required this.genre,
    this.subGenre,
    this.pageCount = 0,
    this.source = 'api',
    this.contributedByUid,
    this.exchangeCount = 0,
    this.wishlistCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookInfoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookInfoModel(
      id: doc.id,
      isbn: data['isbn'],
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      publisher: data['publisher'],
      publishDate: data['publishDate'],
      coverImageUrl: data['coverImageUrl'],
      description: data['description'],
      genre: data['genre'] ?? '기타',
      subGenre: data['subGenre'],
      pageCount: data['pageCount'] ?? 0,
      source: data['source'] ?? 'api',
      contributedByUid: data['contributedByUid'],
      exchangeCount: data['exchangeCount'] ?? 0,
      wishlistCount: data['wishlistCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'isbn': isbn,
      'title': title,
      'author': author,
      'publisher': publisher,
      'publishDate': publishDate,
      'coverImageUrl': coverImageUrl,
      'description': description,
      'genre': genre,
      'subGenre': subGenre,
      'pageCount': pageCount,
      'source': source,
      'contributedByUid': contributedByUid,
      'exchangeCount': exchangeCount,
      'wishlistCount': wishlistCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
