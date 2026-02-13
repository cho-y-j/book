import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nickname;
  final String? profileImageUrl;
  final String email;
  final String? phone;
  final String primaryLocation;
  final GeoPoint geoPoint;
  final double bookTemperature;
  final int totalExchanges;
  final List<String> badges;
  final int level;
  final int points;
  final String notificationSound;
  final Map<String, bool> notificationSettings;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool isVerified;
  final String status;

  const UserModel({
    required this.uid,
    required this.nickname,
    this.profileImageUrl,
    required this.email,
    this.phone,
    required this.primaryLocation,
    required this.geoPoint,
    this.bookTemperature = 36.5,
    this.totalExchanges = 0,
    this.badges = const [],
    this.level = 1,
    this.points = 0,
    this.notificationSound = 'notification_default.mp3',
    this.notificationSettings = const {},
    required this.createdAt,
    required this.lastActiveAt,
    this.isVerified = false,
    this.status = 'active',
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nickname: data['nickname'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      email: data['email'] ?? '',
      phone: data['phone'],
      primaryLocation: data['primaryLocation'] ?? '',
      geoPoint: data['geoPoint'] ?? const GeoPoint(0, 0),
      bookTemperature: (data['bookTemperature'] ?? 36.5).toDouble(),
      totalExchanges: data['totalExchanges'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      level: data['level'] ?? 1,
      points: data['points'] ?? 0,
      notificationSound: data['notificationSound'] ?? 'notification_default.mp3',
      notificationSettings: Map<String, bool>.from(data['notificationSettings'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      status: data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'email': email,
      'phone': phone,
      'primaryLocation': primaryLocation,
      'geoPoint': geoPoint,
      'bookTemperature': bookTemperature,
      'totalExchanges': totalExchanges,
      'badges': badges,
      'level': level,
      'points': points,
      'notificationSound': notificationSound,
      'notificationSettings': notificationSettings,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'isVerified': isVerified,
      'status': status,
    };
  }

  UserModel copyWith({
    String? nickname,
    String? profileImageUrl,
    String? primaryLocation,
    GeoPoint? geoPoint,
    double? bookTemperature,
    int? totalExchanges,
    List<String>? badges,
    int? level,
    int? points,
    String? notificationSound,
    Map<String, bool>? notificationSettings,
    DateTime? lastActiveAt,
    bool? isVerified,
    String? status,
  }) {
    return UserModel(
      uid: uid,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      email: email,
      phone: phone,
      primaryLocation: primaryLocation ?? this.primaryLocation,
      geoPoint: geoPoint ?? this.geoPoint,
      bookTemperature: bookTemperature ?? this.bookTemperature,
      totalExchanges: totalExchanges ?? this.totalExchanges,
      badges: badges ?? this.badges,
      level: level ?? this.level,
      points: points ?? this.points,
      notificationSound: notificationSound ?? this.notificationSound,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
    );
  }
}
