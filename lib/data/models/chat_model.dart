import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String matchId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCount;
  final DateTime createdAt;

  const ChatRoomModel({
    required this.id,
    required this.participants,
    required this.matchId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = const {},
    required this.createdAt,
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
    };
  }
}
