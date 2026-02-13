import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String chatRoomId;
  final String senderUid;
  final String type; // 'text' | 'image' | 'system' | 'location'
  final String content;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderUid,
    this.type = 'text',
    required this.content,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatRoomId: data['chatRoomId'] ?? '',
      senderUid: data['senderUid'] ?? '',
      type: data['type'] ?? 'text',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatRoomId': chatRoomId,
      'senderUid': senderUid,
      'type': type,
      'content': content,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
