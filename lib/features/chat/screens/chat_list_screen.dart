import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../providers/chat_providers.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(chatRoomsProvider);
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
              Text('책 교환을 시작하면 채팅이 생겨요', style: AppTypography.bodySmall),
            ]));
          }
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                title: Text(room.id, style: AppTypography.titleMedium),
                subtitle: Text(room.lastMessage ?? '', style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => context.push(AppRoutes.chatRoomPath(room.id)),
              );
            },
          );
        },
      ),
    );
  }
}
