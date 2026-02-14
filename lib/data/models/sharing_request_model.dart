import 'package:cloud_firestore/cloud_firestore.dart';

class SharingRequestModel {
  final String id;
  final String requesterUid;
  final String ownerUid;
  final String bookId;
  final String bookTitle;
  final String status; // 'pending' | 'accepted' | 'rejected' | 'cancelled' | 'completed'
  final String? message;
  final String? chatRoomId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const SharingRequestModel({
    required this.id,
    required this.requesterUid,
    required this.ownerUid,
    required this.bookId,
    required this.bookTitle,
    this.status = 'pending',
    this.message,
    this.chatRoomId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory SharingRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SharingRequestModel(
      id: doc.id,
      requesterUid: data['requesterUid'] ?? '',
      ownerUid: data['ownerUid'] ?? '',
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      status: data['status'] ?? 'pending',
      message: data['message'],
      chatRoomId: data['chatRoomId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requesterUid': requesterUid,
      'ownerUid': ownerUid,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'status': status,
      'message': message,
      'chatRoomId': chatRoomId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
