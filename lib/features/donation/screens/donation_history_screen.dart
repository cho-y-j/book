import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/donation_providers.dart';

class DonationHistoryScreen extends ConsumerWidget {
  const DonationHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(userDonationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('기증 내역')),
      body: donationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
        data: (donations) {
          if (donations.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.volunteer_activism_outlined, size: 80, color: AppColors.divider),
              const SizedBox(height: 16),
              Text('기증 내역이 없습니다', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text('기관에 책을 기증해보세요!', style: AppTypography.bodySmall),
            ]));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userDonationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemCount: donations.length,
              itemBuilder: (_, i) {
                final d = donations[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(radius: 20, backgroundColor: Colors.blue.withOpacity(0.1), child: const Icon(Icons.volunteer_activism, color: Colors.blue, size: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d.bookTitle, style: AppTypography.titleMedium),
                        const SizedBox(height: 2),
                        Text(d.organizationName, style: AppTypography.bodySmall),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(d.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_statusLabel(d.status), style: AppTypography.caption.copyWith(color: _statusColor(d.status))),
                      ),
                    ]),
                    if (d.message != null && d.message!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(d.message!, style: AppTypography.bodyMedium),
                    ],
                    const SizedBox(height: 4),
                    Text(Formatters.timeAgo(d.createdAt), style: AppTypography.caption),
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
      case 'in_transit': return AppColors.info;
      case 'completed': return Colors.blue;
      case 'cancelled': return AppColors.textSecondary;
      default: return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return '대기중';
      case 'accepted': return '수락됨';
      case 'in_transit': return '배송중';
      case 'completed': return '완료';
      case 'cancelled': return '취소됨';
      default: return status;
    }
  }
}
