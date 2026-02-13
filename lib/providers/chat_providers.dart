import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/chat_repository.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
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
