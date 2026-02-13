import 'package:cloud_firestore/cloud_firestore.dart';

class ExchangeRequestModel {
  final String id;
  final String requesterUid;
  final String ownerUid;
  final String targetBookId;
  final String? selectedBookId;
  final String status;
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? matchedAt;
  final DateTime? completedAt;

  const ExchangeRequestModel({
    required this.id,
    required this.requesterUid,
    required this.ownerUid,
    required this.targetBookId,
    this.selectedBookId,
    this.status = 'pending',
    this.message,
    required this.createdAt,
    required this.updatedAt,
    this.matchedAt,
    this.completedAt,
  });

  factory ExchangeRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExchangeRequestModel(
      id: doc.id,
      requesterUid: data['requesterUid'] ?? '',
      ownerUid: data['ownerUid'] ?? '',
      targetBookId: data['targetBookId'] ?? '',
      selectedBookId: data['selectedBookId'],
      status: data['status'] ?? 'pending',
      message: data['message'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      matchedAt: (data['matchedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requesterUid': requesterUid,
      'ownerUid': ownerUid,
      'targetBookId': targetBookId,
      'selectedBookId': selectedBookId,
      'status': status,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'matchedAt': matchedAt != null ? Timestamp.fromDate(matchedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
