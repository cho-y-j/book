import 'package:cloud_firestore/cloud_firestore.dart';

class BookClubModel {
  final String id;
  final String name;
  final String description;
  final String creatorUid;
  final String location;
  final GeoPoint geoPoint;
  final List<String> memberUids;
  final int maxMembers;
  final String? currentBookInfoId;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? nextMeetingAt;

  const BookClubModel({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorUid,
    required this.location,
    required this.geoPoint,
    this.memberUids = const [],
    this.maxMembers = 20,
    this.currentBookInfoId,
    this.imageUrl,
    required this.createdAt,
    this.nextMeetingAt,
  });

  factory BookClubModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookClubModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      creatorUid: data['creatorUid'] ?? '',
      location: data['location'] ?? '',
      geoPoint: data['geoPoint'] ?? const GeoPoint(0, 0),
      memberUids: List<String>.from(data['memberUids'] ?? []),
      maxMembers: data['maxMembers'] ?? 20,
      currentBookInfoId: data['currentBookInfoId'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nextMeetingAt: (data['nextMeetingAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'creatorUid': creatorUid,
      'location': location,
      'geoPoint': geoPoint,
      'memberUids': memberUids,
      'maxMembers': maxMembers,
      'currentBookInfoId': currentBookInfoId,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'nextMeetingAt': nextMeetingAt != null ? Timestamp.fromDate(nextMeetingAt!) : null,
    };
  }
}
