import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/auto_greeting_helper.dart';
import '../../../providers/purchase_providers.dart';
import '../../../providers/chat_providers.dart';
import '../../../providers/auth_providers.dart';

class IncomingPurchaseRequestsScreen extends ConsumerWidget {
  const IncomingPurchaseRequestsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(incomingPurchaseRequestsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('받은 구매 요청')),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.inbox_outlined, size: 80, color: AppColors.divider),
              const SizedBox(height: 16),
              Text('받은 구매 요청이 없습니다', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
            ]));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(incomingPurchaseRequestsProvider),
            child: ListView.builder(
              itemCount: requests.length,
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemBuilder: (_, i) {
                final req = requests[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(radius: 20, backgroundColor: AppColors.primaryLight.withOpacity(0.3), child: const Icon(Icons.person, color: AppColors.primary, size: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(req.bookTitle, style: AppTypography.titleMedium),
                        const SizedBox(height: 2),
                        Text('구매자: ${req.buyerUid}', style: AppTypography.bodySmall),
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
                    const SizedBox(height: 8),
                    Text('${Formatters.formatPrice(req.price)}원', style: AppTypography.titleLarge.copyWith(color: AppColors.accent)),
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
                            await ref.read(purchaseRepositoryProvider).updateStatus(req.id, 'rejected');
                            ref.invalidate(incomingPurchaseRequestsProvider);
                          },
                          child: const Text('거절'),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: ElevatedButton(
                          onPressed: () async {
                            final user = ref.read(currentUserProvider);
                            if (user == null) return;
                            // 1. 수락 처리
                            await ref.read(purchaseRepositoryProvider).updateStatus(req.id, 'accepted');
                            ref.invalidate(incomingPurchaseRequestsProvider);
                            // 2. 기존 채팅방으로 이동 (요청 시 이미 생성됨)
                            if (req.chatRoomId != null && context.mounted) {
                              context.push(AppRoutes.chatRoomPath(req.chatRoomId!));
                            } else if (user != null) {
                              // 하위호환: 이전에 생성된 요청은 chatRoomId 없음 → 새로 생성
                              final greeting = AutoGreetingHelper.getGreeting(
                                transactionType: 'sale',
                                bookTitle: req.bookTitle,
                                price: req.price,
                              );
                              final chatRoomId = await ref.read(chatRepositoryProvider).createTransactionChatRoom(
                                participants: [user.uid, req.buyerUid],
                                transactionType: 'sale',
                                bookTitle: req.bookTitle,
                                bookId: req.bookId,
                                senderUid: user.uid,
                                autoGreetingMessage: greeting,
                              );
                              await ref.read(purchaseRepositoryProvider).updateChatRoomId(req.id, chatRoomId);
                              if (context.mounted) {
                                context.push(AppRoutes.chatRoomPath(chatRoomId));
                              }
                            }
                          },
                          child: const Text('수락'),
                        )),
                      ]),
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
      case 'pending':
        return AppColors.warning;
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return '대기중';
      case 'accepted':
        return '수락됨';
      case 'rejected':
        return '거절됨';
      case 'completed':
        return '완료';
      case 'cancelled':
        return '취소됨';
      default:
        return status;
    }
  }
}
