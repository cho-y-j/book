import 'package:cloud_firestore/cloud_firestore.dart';
import 'delivery_model.dart';

class MatchModel {
  final String id;
  final String exchangeRequestId;
  final String userAUid;
  final String userBUid;
  final String bookAId;
  final String bookBId;
  final String exchangeMethod; // 'local' | 'delivery'
  final String? meetingLocation;
  final GeoPoint? meetingGeoPoint;
  final DateTime? meetingDateTime;
  final String status; // 'confirmed' | 'in_progress' | 'completed' | 'cancelled'
  final String chatRoomId;
  final DeliveryModel? deliveryA;
  final DeliveryModel? deliveryB;
  final bool userAConfirmed;
  final bool userBConfirmed;
  final DateTime createdAt;
  final DateTime? completedAt;

  const MatchModel({
    required this.id,
    required this.exchangeRequestId,
    required this.userAUid,
    required this.userBUid,
    required this.bookAId,
    required this.bookBId,
    required this.exchangeMethod,
    this.meetingLocation,
    this.meetingGeoPoint,
    this.meetingDateTime,
    this.status = 'confirmed',
    required this.chatRoomId,
    this.deliveryA,
    this.deliveryB,
    this.userAConfirmed = false,
    this.userBConfirmed = false,
    required this.createdAt,
    this.completedAt,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      id: doc.id,
      exchangeRequestId: data['exchangeRequestId'] ?? '',
      userAUid: data['userAUid'] ?? '',
      userBUid: data['userBUid'] ?? '',
      bookAId: data['bookAId'] ?? '',
      bookBId: data['bookBId'] ?? '',
      exchangeMethod: data['exchangeMethod'] ?? 'local',
      meetingLocation: data['meetingLocation'],
      meetingGeoPoint: data['meetingGeoPoint'],
      meetingDateTime: (data['meetingDateTime'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'confirmed',
      chatRoomId: data['chatRoomId'] ?? '',
      deliveryA: data['deliveryA'] != null
          ? DeliveryModel.fromMap(data['deliveryA'])
          : null,
      deliveryB: data['deliveryB'] != null
          ? DeliveryModel.fromMap(data['deliveryB'])
          : null,
      userAConfirmed: data['userAConfirmed'] ?? false,
      userBConfirmed: data['userBConfirmed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'exchangeRequestId': exchangeRequestId,
      'userAUid': userAUid,
      'userBUid': userBUid,
      'bookAId': bookAId,
      'bookBId': bookBId,
      'exchangeMethod': exchangeMethod,
      'meetingLocation': meetingLocation,
      'meetingGeoPoint': meetingGeoPoint,
      'meetingDateTime': meetingDateTime != null ? Timestamp.fromDate(meetingDateTime!) : null,
      'status': status,
      'chatRoomId': chatRoomId,
      'deliveryA': deliveryA?.toMap(),
      'deliveryB': deliveryB?.toMap(),
      'userAConfirmed': userAConfirmed,
      'userBConfirmed': userBConfirmed,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
