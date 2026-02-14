import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String id;
  final String donorUid;
  final String bookId;
  final String bookTitle;
  final String organizationId;
  final String organizationName;
  final String status; // 'pending' | 'accepted' | 'in_transit' | 'completed' | 'cancelled'
  final String? message;
  final String? deliveryMethod; // 'courier_request' | 'cod_shipping' | 'in_person'
  final String? donorAddress;
  final String? chatRoomId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const DonationModel({
    required this.id,
    required this.donorUid,
    required this.bookId,
    required this.bookTitle,
    required this.organizationId,
    required this.organizationName,
    this.status = 'pending',
    this.message,
    this.deliveryMethod,
    this.donorAddress,
    this.chatRoomId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory DonationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DonationModel(
      id: doc.id,
      donorUid: data['donorUid'] ?? '',
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      organizationId: data['organizationId'] ?? '',
      organizationName: data['organizationName'] ?? '',
      status: data['status'] ?? 'pending',
      message: data['message'],
      deliveryMethod: data['deliveryMethod'],
      donorAddress: data['donorAddress'],
      chatRoomId: data['chatRoomId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'donorUid': donorUid,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'status': status,
      'message': message,
      if (deliveryMethod != null) 'deliveryMethod': deliveryMethod,
      if (donorAddress != null) 'donorAddress': donorAddress,
      if (chatRoomId != null) 'chatRoomId': chatRoomId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
