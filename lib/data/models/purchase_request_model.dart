import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseRequestModel {
  final String id;
  final String buyerUid;
  final String sellerUid;
  final String bookId;
  final String bookTitle;
  final int price;
  final String status; // 'pending' | 'accepted' | 'rejected' | 'cancelled' | 'completed'
  final String? message;
  final String? chatRoomId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const PurchaseRequestModel({
    required this.id,
    required this.buyerUid,
    required this.sellerUid,
    required this.bookId,
    required this.bookTitle,
    required this.price,
    this.status = 'pending',
    this.message,
    this.chatRoomId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory PurchaseRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PurchaseRequestModel(
      id: doc.id,
      buyerUid: data['buyerUid'] ?? '',
      sellerUid: data['sellerUid'] ?? '',
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      price: data['price'] ?? 0,
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
      'buyerUid': buyerUid,
      'sellerUid': sellerUid,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'price': price,
      'status': status,
      'message': message,
      'chatRoomId': chatRoomId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
