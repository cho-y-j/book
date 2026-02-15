import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/chat_providers.dart';
import '../../../providers/auth_providers.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);
    final currentUid = ref.watch(currentUserProvider)?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('채팅')),
      body: chatRoomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('채팅 목록을 불러올 수 없습니다', style: AppTypography.bodyMedium)),
        data: (rooms) {
          if (rooms.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.chat_bubble_outline, size: 80, color: AppColors.divider),
              const SizedBox(height: 16),
              Text('채팅이 없습니다', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text('교환/구매/나눔/기증을 시작하면 채팅이 생겨요', style: AppTypography.bodySmall),
            ]));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(chatRoomsProvider),
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final icon = _transactionIcon(room.transactionType);
                final title = room.bookTitle != null
                    ? '$icon ${room.bookTitle}'
                    : '$icon 채팅';
                final unread = currentUid != null
                    ? (room.unreadCount[currentUid] ?? 0)
                    : 0;
                return Dismissible(
                  key: Key(room.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('채팅방 나가기'),
                        content: const Text('이 채팅방을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) {
                    // TODO: 채팅방 삭제 구현 (participants에서 제거)
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                      child: Text(icon, style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(title, style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(room.lastMessage ?? '', style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (room.lastMessageAt != null)
                          Text(
                            Formatters.timeAgo(room.lastMessageAt!),
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        if (unread > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () => context.push(AppRoutes.chatRoomPath(room.id)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
