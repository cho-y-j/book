import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String? contactInfo;
  final String? imageUrl;
  final String category; // 'library' | 'school' | 'ngo'
  final bool isActive;
  final String? welcomeMessage;
  final DateTime createdAt;
  // 신규 필드
  final GeoPoint? geoPoint;
  final List<String> wishBooks; // 희망 장르 ['소설','과학']
  final String? region; // '서울특별시'
  final String? subRegion; // '중구'
  final String? contactPhone;
  final String? operatingHours; // '09:00 - 18:00'
  final String? ownerUid; // 등록한 파트너 UID

  const OrganizationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.contactInfo,
    this.imageUrl,
    required this.category,
    this.isActive = true,
    this.welcomeMessage,
    required this.createdAt,
    this.geoPoint,
    this.wishBooks = const [],
    this.region,
    this.subRegion,
    this.contactPhone,
    this.operatingHours,
    this.ownerUid,
  });

  factory OrganizationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrganizationModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      contactInfo: data['contactInfo'],
      imageUrl: data['imageUrl'],
      category: data['category'] ?? 'library',
      isActive: data['isActive'] ?? true,
      welcomeMessage: data['welcomeMessage'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      geoPoint: data['geoPoint'] as GeoPoint?,
      wishBooks: List<String>.from(data['wishBooks'] ?? []),
      region: data['region'],
      subRegion: data['subRegion'],
      contactPhone: data['contactPhone'],
      operatingHours: data['operatingHours'],
      ownerUid: data['ownerUid'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'contactInfo': contactInfo,
      'imageUrl': imageUrl,
      'category': category,
      'isActive': isActive,
      if (welcomeMessage != null) 'welcomeMessage': welcomeMessage,
      'createdAt': Timestamp.fromDate(createdAt),
      if (geoPoint != null) 'geoPoint': geoPoint,
      'wishBooks': wishBooks,
      if (region != null) 'region': region,
      if (subRegion != null) 'subRegion': subRegion,
      if (contactPhone != null) 'contactPhone': contactPhone,
      if (operatingHours != null) 'operatingHours': operatingHours,
      if (ownerUid != null) 'ownerUid': ownerUid,
    };
  }

  OrganizationModel copyWith({
    String? name,
    String? description,
    String? address,
    String? contactInfo,
    String? imageUrl,
    String? category,
    bool? isActive,
    String? welcomeMessage,
    GeoPoint? geoPoint,
    List<String>? wishBooks,
    String? region,
    String? subRegion,
    String? contactPhone,
    String? operatingHours,
    String? ownerUid,
  }) {
    return OrganizationModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      contactInfo: contactInfo ?? this.contactInfo,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      createdAt: createdAt,
      geoPoint: geoPoint ?? this.geoPoint,
      wishBooks: wishBooks ?? this.wishBooks,
      region: region ?? this.region,
      subRegion: subRegion ?? this.subRegion,
      contactPhone: contactPhone ?? this.contactPhone,
      operatingHours: operatingHours ?? this.operatingHours,
      ownerUid: ownerUid ?? this.ownerUid,
    );
  }
}
