import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/exchange_providers.dart';

class IncomingRequestsScreen extends ConsumerWidget {
  const IncomingRequestsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(incomingRequestsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('받은 요청')),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.inbox_outlined, size: 80, color: AppColors.divider),
              const SizedBox(height: 16),
              Text('받은 요청이 없습니다', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
            ]));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(incomingRequestsProvider),
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
                        Text(req.requesterUid, style: AppTypography.titleMedium),
                        Text(req.message ?? '', style: AppTypography.caption),
                      ])),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: OutlinedButton(
                        onPressed: () async {
                          await ref.read(exchangeRepositoryProvider).updateRequestStatus(req.id, 'rejected');
                          ref.invalidate(incomingRequestsProvider);
                        },
                        child: const Text('거절'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(
                        onPressed: () => context.push(
                          AppRoutes.requesterBookshelfPath(req.requesterUid),
                          extra: {'exchangeRequestId': req.id, 'targetBookId': req.targetBookId},
                        ),
                        child: const Text('책장 보기'),
                      )),
                    ]),
                  ])),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
