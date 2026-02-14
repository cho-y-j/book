import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String ownerUid;
  final String bookInfoId;
  final String title;
  final String author;
  final String? coverImageUrl;
  final List<String> conditionPhotos;
  final String condition; // 'best' | 'good' | 'fair' | 'poor'
  final String? conditionNote;
  final String status; // 'available' | 'reserved' | 'exchanged' | 'sold' | 'hidden'
  final String exchangeType; // 'local_only' | 'delivery_only' | 'both'
  final String listingType; // 'exchange' | 'sale' | 'both'
  final int? price; // 원 단위, 판매가 (교환만이면 null)
  final bool isDealer; // 업자 등록 여부
  final String location;
  final GeoPoint geoPoint;
  final String genre;
  final List<String> tags;
  final int viewCount;
  final int wishCount;
  final int requestCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? publisher;
  final String? pubDate;
  final String? description;
  final int? originalPrice;

  const BookModel({
    required this.id,
    required this.ownerUid,
    required this.bookInfoId,
    required this.title,
    required this.author,
    this.coverImageUrl,
    this.conditionPhotos = const [],
    required this.condition,
    this.conditionNote,
    this.status = 'available',
    this.exchangeType = 'both',
    this.listingType = 'exchange',
    this.price,
    this.isDealer = false,
    required this.location,
    required this.geoPoint,
    required this.genre,
    this.tags = const [],
    this.viewCount = 0,
    this.wishCount = 0,
    this.requestCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.publisher,
    this.pubDate,
    this.description,
    this.originalPrice,
  });

  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      id: doc.id,
      ownerUid: data['ownerUid'] ?? '',
      bookInfoId: data['bookInfoId'] ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      coverImageUrl: data['coverImageUrl'],
      conditionPhotos: List<String>.from(data['conditionPhotos'] ?? []),
      condition: data['condition'] ?? 'good',
      conditionNote: data['conditionNote'],
      status: data['status'] ?? 'available',
      exchangeType: data['exchangeType'] ?? 'both',
      listingType: data['listingType'] ?? 'exchange',
      price: data['price'],
      isDealer: data['isDealer'] ?? false,
      location: data['location'] ?? '',
      geoPoint: data['geoPoint'] ?? const GeoPoint(0, 0),
      genre: data['genre'] ?? '기타',
      tags: List<String>.from(data['tags'] ?? []),
      viewCount: data['viewCount'] ?? 0,
      wishCount: data['wishCount'] ?? 0,
      requestCount: data['requestCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publisher: data['publisher'],
      pubDate: data['pubDate'],
      description: data['description'],
      originalPrice: data['originalPrice'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerUid': ownerUid,
      'bookInfoId': bookInfoId,
      'title': title,
      'author': author,
      'coverImageUrl': coverImageUrl,
      'conditionPhotos': conditionPhotos,
      'condition': condition,
      'conditionNote': conditionNote,
      'status': status,
      'exchangeType': exchangeType,
      'listingType': listingType,
      'price': price,
      'isDealer': isDealer,
      'location': location,
      'geoPoint': geoPoint,
      'genre': genre,
      'tags': tags,
      'viewCount': viewCount,
      'wishCount': wishCount,
      'requestCount': requestCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'publisher': publisher,
      'pubDate': pubDate,
      'description': description,
      'originalPrice': originalPrice,
    };
  }

  BookModel copyWith({
    String? condition,
    String? conditionNote,
    List<String>? conditionPhotos,
    String? status,
    String? exchangeType,
    String? listingType,
    int? price,
    String? location,
    GeoPoint? geoPoint,
    List<String>? tags,
    String? publisher,
    String? pubDate,
    String? description,
    int? originalPrice,
  }) {
    return BookModel(
      id: id,
      ownerUid: ownerUid,
      bookInfoId: bookInfoId,
      title: title,
      author: author,
      coverImageUrl: coverImageUrl,
      conditionPhotos: conditionPhotos ?? this.conditionPhotos,
      condition: condition ?? this.condition,
      conditionNote: conditionNote ?? this.conditionNote,
      status: status ?? this.status,
      exchangeType: exchangeType ?? this.exchangeType,
      listingType: listingType ?? this.listingType,
      price: price ?? this.price,
      isDealer: isDealer,
      location: location ?? this.location,
      geoPoint: geoPoint ?? this.geoPoint,
      genre: genre,
      tags: tags ?? this.tags,
      viewCount: viewCount,
      wishCount: wishCount,
      requestCount: requestCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      publisher: publisher ?? this.publisher,
      pubDate: pubDate ?? this.pubDate,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
    );
  }
}
