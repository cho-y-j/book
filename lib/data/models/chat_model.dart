import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String matchId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  // 거래 컨텍스트
  final String? transactionType; // 'exchange'|'sale'|'sharing'|'donation'
  final String? bookTitle;
  final String? bookId;
  final String? deliveryMethod; // 'courier_request'|'cod_shipping'|'in_person'
  final String? organizationId;

  const ChatRoomModel({
    required this.id,
    required this.participants,
    required this.matchId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = const {},
    required this.createdAt,
    this.transactionType,
    this.bookTitle,
    this.bookId,
    this.deliveryMethod,
    this.organizationId,
  });

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      matchId: data['matchId'] ?? '',
      lastMessage: data['lastMessage'],
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionType: data['transactionType'],
      bookTitle: data['bookTitle'],
      bookId: data['bookId'],
      deliveryMethod: data['deliveryMethod'],
      organizationId: data['organizationId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'matchId': matchId,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      if (transactionType != null) 'transactionType': transactionType,
      if (bookTitle != null) 'bookTitle': bookTitle,
      if (bookId != null) 'bookId': bookId,
      if (deliveryMethod != null) 'deliveryMethod': deliveryMethod,
      if (organizationId != null) 'organizationId': organizationId,
    };
  }
}
