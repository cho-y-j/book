import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/purchase_providers.dart';

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
                            await ref.read(purchaseRepositoryProvider).updateStatus(req.id, 'accepted');
                            ref.invalidate(incomingPurchaseRequestsProvider);
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
