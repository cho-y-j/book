import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/chat_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../data/models/message_model.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatRoomId;
  const ChatRoomScreen({super.key, required this.chatRoomId});
  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() { _messageController.dispose(); _scrollController.dispose(); super.dispose(); }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final message = MessageModel(
      id: '',
      chatRoomId: widget.chatRoomId,
      senderUid: user.uid,
      content: text,
      type: 'text',
      createdAt: DateTime.now(),
    );
    ref.read(chatRepositoryProvider).sendMessage(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.chatRoomId));
    final currentUid = ref.watch(currentUserProvider)?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅', style: AppTypography.titleMedium),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: Column(children: [
        Expanded(child: messagesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('메시지를 불러올 수 없습니다', style: AppTypography.bodyMedium)),
          data: (messages) {
            if (messages.isEmpty) return Center(child: Text('메시지가 없습니다.\n첫 메시지를 보내보세요!', textAlign: TextAlign.center, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)));
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                final isMe = msg.senderUid == currentUid;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Text(msg.content, style: AppTypography.bodyMedium.copyWith(color: isMe ? Colors.white : AppColors.textPrimary)),
                  ),
                );
              },
            );
          },
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))]),
          child: SafeArea(child: Row(children: [
            Expanded(child: TextField(controller: _messageController, decoration: InputDecoration(hintText: '메시지 입력', border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true, fillColor: AppColors.background, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)), onSubmitted: (_) => _sendMessage())),
            const SizedBox(width: 8),
            CircleAvatar(backgroundColor: AppColors.primary, child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: _sendMessage)),
          ])),
        ),
      ]),
    );
  }
}
