import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/auto_greeting_helper.dart';
import '../../../providers/sharing_providers.dart';
import '../../../providers/chat_providers.dart';
import '../../../providers/auth_providers.dart';

class IncomingSharingRequestsScreen extends ConsumerWidget {
  const IncomingSharingRequestsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(incomingSharingRequestsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('받은 나눔 요청')),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.inbox_outlined, size: 80, color: AppColors.divider),
              const SizedBox(height: 16),
              Text('받은 나눔 요청이 없습니다', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
            ]));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(incomingSharingRequestsProvider),
            child: ListView.builder(
              itemCount: requests.length,
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemBuilder: (_, i) {
                final req = requests[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(radius: 20, backgroundColor: Colors.green.withOpacity(0.2), child: const Icon(Icons.volunteer_activism, color: Colors.green, size: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(req.bookTitle, style: AppTypography.titleMedium),
                        const SizedBox(height: 2),
                        Text('요청자: ${req.requesterUid.substring(0, 8)}...', style: AppTypography.bodySmall),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(req.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_statusLabel(req.status), style: AppTypography.caption.copyWith(color: _statusColor(req.status))),
                      ),
                    ]),
                    if (req.message != null && req.message!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(req.message!, style: AppTypography.bodyMedium),
                    ],
                    const SizedBox(height: 4),
                    Text(Formatters.timeAgo(req.createdAt), style: AppTypography.caption),
                    if (req.status == 'pending') ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: OutlinedButton(
                          onPressed: () async {
                            await ref.read(sharingRepositoryProvider).updateStatus(req.id, 'rejected');
                            ref.invalidate(incomingSharingRequestsProvider);
                          },
                          child: const Text('거절'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () async {
                            final user = ref.read(currentUserProvider);
                            // 1. 수락 처리
                            await ref.read(sharingRepositoryProvider).updateStatus(req.id, 'accepted');
                            // 2. 채팅방 생성 + 자동 인사말
                            if (user != null) {
                              final greeting = AutoGreetingHelper.getGreeting(
                                transactionType: 'sharing',
                                bookTitle: req.bookTitle,
                              );
                              final chatRoomId = await ref.read(chatRepositoryProvider).createTransactionChatRoom(
                                participants: [req.ownerUid, req.requesterUid],
                                transactionType: 'sharing',
                                bookTitle: req.bookTitle,
                                bookId: req.bookId,
                                senderUid: user.uid,
                                autoGreetingMessage: greeting,
                              );
                              // 3. chatRoomId 저장
                              await ref.read(sharingRepositoryProvider).updateChatRoomId(req.id, chatRoomId);
                              ref.invalidate(incomingSharingRequestsProvider);
                              // 4. 채팅방으로 이동
                              if (context.mounted) {
                                context.push(AppRoutes.chatRoomPath(chatRoomId));
                              }
                            }
                          },
                          child: const Text('수락'),
                        )),
                      ]),
                    ],
                    if (req.status == 'accepted') ...[
                      const SizedBox(height: 12),
                      SizedBox(width: double.infinity, child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          await ref.read(sharingRepositoryProvider).updateStatus(req.id, 'completed');
                          ref.invalidate(incomingSharingRequestsProvider);
                        },
                        child: const Text('나눔 완료'),
                      )),
                    ],
                  ])),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'accepted': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'completed': return AppColors.info;
      case 'cancelled': return AppColors.textSecondary;
      default: return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return '대기중';
      case 'accepted': return '수락됨';
      case 'rejected': return '거절됨';
      case 'completed': return '완료';
      case 'cancelled': return '취소됨';
      default: return status;
    }
  }
}
