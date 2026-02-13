import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../../core/constants/api_constants.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chatRoomsRef =>
      _firestore.collection(ApiConstants.chatRoomsCollection);

  CollectionReference<Map<String, dynamic>> get _messagesRef =>
      _firestore.collection(ApiConstants.messagesCollection);

  Future<String> createChatRoom(ChatRoomModel chatRoom) async {
    final doc = _chatRoomsRef.doc(chatRoom.id);
    await doc.set(chatRoom.toFirestore());
    return doc.id;
  }

  Stream<List<ChatRoomModel>> watchChatRooms(String uid) {
    return _chatRoomsRef
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatRoomModel.fromFirestore(d)).toList());
  }

  Stream<List<MessageModel>> watchMessages(String chatRoomId) {
    return _messagesRef
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MessageModel.fromFirestore(d)).toList());
  }

  Future<void> sendMessage(MessageModel message) async {
    await _messagesRef.add(message.toFirestore());
    await _chatRoomsRef.doc(message.chatRoomId).update({
      'lastMessage': message.content,
      'lastMessageAt': Timestamp.fromDate(message.createdAt),
    });
  }

  Future<void> markAsRead(String chatRoomId, String uid) async {
    await _chatRoomsRef.doc(chatRoomId).update({
      'unreadCount.$uid': 0,
    });
  }
}
