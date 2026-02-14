import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/chat_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/donation_providers.dart';
import '../../../data/models/message_model.dart';
import '../widgets/exchange_status_message.dart';
import '../widgets/quick_reply_bar.dart';
import '../widgets/delivery_method_card.dart';
import '../widgets/ai_suggestion_chip.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatRoomId;
  const ChatRoomScreen({super.key, required this.chatRoomId});
  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _aiSuggestion;
  bool _aiLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? text]) {
    final content = text ?? _messageController.text.trim();
    if (content.isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final message = MessageModel(
      id: '',
      chatRoomId: widget.chatRoomId,
      senderUid: user.uid,
      content: content,
      type: 'text',
      createdAt: DateTime.now(),
    );
    ref.read(chatRepositoryProvider).sendMessage(message);
    _messageController.clear();
    setState(() => _aiSuggestion = null);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _requestAiSuggestion() async {
    final chatRoom = ref.read(chatRoomDetailProvider(widget.chatRoomId)).value;
    if (chatRoom == null) return;

    setState(() {
      _aiLoading = true;
      _aiSuggestion = null;
    });

    try {
      final suggestion = await ref.read(
        aiReplySuggestionProvider((
          chatRoomId: widget.chatRoomId,
          bookTitle: chatRoom.bookTitle ?? '',
          transactionType: chatRoom.transactionType ?? '',
        )).future,
      );
      if (mounted && suggestion.isNotEmpty) {
        setState(() => _aiSuggestion = suggestion);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI 답변을 생성할 수 없습니다')),
        );
      }
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  Future<void> _handleDeliverySelect(String method) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final chatRepo = ref.read(chatRepositoryProvider);
    final chatRoom = ref.read(chatRoomDetailProvider(widget.chatRoomId)).value;

    // 채팅방 deliveryMethod 업데이트
    await chatRepo.updateDeliveryMethod(widget.chatRoomId, method);

    // 전달 방법 선택 시스템 메시지
    final methodLabel = switch (method) {
      'courier_request' => '택배 요청',
      'cod_shipping' => '착불 발송',
      'in_person' => '직접 방문 전달',
      _ => method,
    };
    await chatRepo.sendSystemMessage(
      widget.chatRoomId,
      user.uid,
      '전달 방법: $methodLabel',
      type: 'system',
    );

    // 주소 연계 메시지
    if (method == 'courier_request') {
      // 사용자 주소 확인
      final userProfile = ref.read(currentUserProfileProvider).value;
      final address = userProfile?.primaryLocation;
      if (address != null && address.isNotEmpty) {
        await chatRepo.sendSystemMessage(
          widget.chatRoomId,
          user.uid,
          '기부자님 주소지 $address이(가) 맞나요? 맞으면 택배 수거를 요청하겠습니다.',
          type: 'system',
        );
      } else {
        await chatRepo.sendSystemMessage(
          widget.chatRoomId,
          user.uid,
          '개인정보에 주소가 없어 주소지를 요청드립니다. 주소를 입력해주세요.',
          type: 'system',
        );
      }
    } else if (method == 'cod_shipping' || method == 'in_person') {
      // 기관 주소 표시 - chatRoom의 organizationId로 기관 주소 찾기
      // 간단히 시스템 메시지로 안내
      if (chatRoom?.organizationId != null) {
        final orgsAsync = ref.read(organizationsStreamProvider);
        final org = orgsAsync.value?.where((o) => o.id == chatRoom!.organizationId).firstOrNull;
        if (org != null) {
          final prefix = method == 'cod_shipping' ? '착불로 보내주세요' : '방문해주세요';
          await chatRepo.sendSystemMessage(
            widget.chatRoomId,
            user.uid,
            '기관 주소: ${org.address}\n$prefix.',
            type: 'system',
          );
          if (method == 'in_person') {
            await chatRepo.sendSystemMessage(
              widget.chatRoomId,
              user.uid,
              '방문 가능한 시간을 알려주세요.',
              type: 'system',
            );
          }
        }
      }
    }
  }

  String _transactionIcon(String? type) {
    return switch (type) {
      'exchange' => '🔄',
      'sale' => '💰',
      'sharing' => '📚',
      'donation' => '🎁',
      _ => '💬',
    };
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.chatRoomId));
    final chatRoomAsync = ref.watch(chatRoomDetailProvider(widget.chatRoomId));
    final currentUid = ref.watch(currentUserProvider)?.uid;
    final chatRoom = chatRoomAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chatRoom?.bookTitle != null
              ? '${_transactionIcon(chatRoom?.transactionType)} ${chatRoom!.bookTitle}'
              : '채팅',
          style: AppTypography.titleMedium,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        // 메시지 리스트
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('메시지를 불러올 수 없습니다',
                  style: AppTypography.bodyMedium),
            ),
            data: (messages) {
              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    '메시지가 없습니다.\n첫 메시지를 보내보세요!',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                );
              }
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                itemCount: messages.length,
                itemBuilder: (_, i) => _buildMessage(messages[i], currentUid, chatRoom),
              );
            },
          ),
        ),

        // 빠른 답변 바
        QuickReplyBar(
          transactionType: chatRoom?.transactionType,
          onQuickReply: (text) => _sendMessage(text),
        ),

        // AI 답변 칩
        if (_aiLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: LinearProgressIndicator(),
          ),
        if (_aiSuggestion != null)
          AiSuggestionChip(
            suggestion: _aiSuggestion!,
            onTap: () => _sendMessage(_aiSuggestion),
            onDismiss: () => setState(() => _aiSuggestion = null),
          ),

        // 입력바
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(children: [
              // AI 버튼
              IconButton(
                icon: Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: _aiLoading ? Colors.grey : Colors.deepPurple,
                ),
                onPressed: _aiLoading ? null : _requestAiSuggestion,
                tooltip: 'AI 답변 추천',
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: '메시지 입력',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: () => _sendMessage(),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildMessage(MessageModel msg, String? currentUid, dynamic chatRoom) {
    // 시스템/자동인사 메시지
    if (msg.type == 'system' || msg.type == 'auto_greeting') {
      return ExchangeStatusMessage(message: msg.content);
    }

    // 전달 방법 선택 카드
    if (msg.type == 'delivery_select') {
      return DeliveryMethodCard(
        selectedMethod: chatRoom?.deliveryMethod,
        isSelectable: msg.senderUid == currentUid && chatRoom?.deliveryMethod == null,
        onSelect: (method) => _handleDeliverySelect(method),
      );
    }

    // 일반 메시지
    final isMe = msg.senderUid == currentUid;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Text(
          msg.content,
          style: AppTypography.bodyMedium.copyWith(
              color: isMe ? Colors.white : AppColors.textPrimary),
        ),
      ),
    );
  }
}
