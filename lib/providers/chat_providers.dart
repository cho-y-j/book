import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/chat_repository.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../data/datasources/remote/deepseek_datasource.dart';
import 'auth_providers.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatRoomsProvider = StreamProvider<List<ChatRoomModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(chatRepositoryProvider).watchChatRooms(user.uid);
});

final messagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatRoomId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatRoomId);
});

/// 채팅방 단건 스트림 (거래 컨텍스트 로드용)
final chatRoomDetailProvider = StreamProvider.family<ChatRoomModel?, String>((ref, chatRoomId) {
  return ref.watch(chatRepositoryProvider).watchChatRoom(chatRoomId);
});

/// DeepSeek AI 데이터소스
final deepSeekDatasourceProvider = Provider<DeepSeekDatasource>((ref) {
  return DeepSeekDatasource();
});

/// AI 답변 추천 (on-demand)
final aiReplySuggestionProvider = FutureProvider.family<String, ({String chatRoomId, String bookTitle, String transactionType, bool isRequester})>((ref, params) async {
  final recentMessages = await ref.read(chatRepositoryProvider)
      .getRecentMessages(params.chatRoomId, limit: 5);
  // auto_greeting, system, text 모두 포함 → AI가 전체 맥락 파악
  final messageTexts = recentMessages
      .map((m) => m.content)
      .toList();
  return ref.read(deepSeekDatasourceProvider).generateReplySuggestion(
    bookTitle: params.bookTitle,
    transactionType: params.transactionType,
    recentMessages: messageTexts,
    isRequester: params.isRequester,
  );
});
