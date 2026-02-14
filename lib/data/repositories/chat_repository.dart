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

  /// 거래 컨텍스트 포함 채팅방 생성 + 자동 인사말 (WriteBatch)
  Future<String> createTransactionChatRoom({
    required List<String> participants,
    required String transactionType,
    required String bookTitle,
    required String bookId,
    required String senderUid,
    String? organizationId,
    String? autoGreetingMessage,
  }) async {
    final batch = _firestore.batch();
    final chatRoomDoc = _chatRoomsRef.doc();
    final chatRoomId = chatRoomDoc.id;
    final now = Timestamp.now();

    final chatRoom = ChatRoomModel(
      id: chatRoomId,
      participants: participants,
      matchId: '',
      lastMessage: autoGreetingMessage,
      lastMessageAt: now.toDate(),
      createdAt: now.toDate(),
      transactionType: transactionType,
      bookTitle: bookTitle,
      bookId: bookId,
      organizationId: organizationId,
    );
    batch.set(chatRoomDoc, chatRoom.toFirestore());

    if (autoGreetingMessage != null) {
      final msgDoc = _messagesRef.doc();
      final greeting = MessageModel(
        id: msgDoc.id,
        chatRoomId: chatRoomId,
        senderUid: senderUid,
        type: 'auto_greeting',
        content: autoGreetingMessage,
        createdAt: now.toDate(),
      );
      batch.set(msgDoc, greeting.toFirestore());
    }

    await batch.commit();
    return chatRoomId;
  }

  /// 시스템 메시지 전송
  Future<void> sendSystemMessage(
    String chatRoomId,
    String senderUid,
    String content, {
    String type = 'system',
    Map<String, dynamic>? metadata,
  }) async {
    final message = MessageModel(
      id: '',
      chatRoomId: chatRoomId,
      senderUid: senderUid,
      type: type,
      content: content,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
    await sendMessage(message);
  }

  /// 채팅방 단건 스트림
  Stream<ChatRoomModel?> watchChatRoom(String chatRoomId) {
    return _chatRoomsRef.doc(chatRoomId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return ChatRoomModel.fromFirestore(snap);
    });
  }

  /// 최근 N개 메시지 (AI 컨텍스트용)
  Future<List<MessageModel>> getRecentMessages(String chatRoomId, {int limit = 3}) async {
    final snap = await _messagesRef
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => MessageModel.fromFirestore(d)).toList().reversed.toList();
  }

  /// 채팅방 deliveryMethod 업데이트
  Future<void> updateDeliveryMethod(String chatRoomId, String deliveryMethod) async {
    await _chatRoomsRef.doc(chatRoomId).update({
      'deliveryMethod': deliveryMethod,
    });
  }
}
