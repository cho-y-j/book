import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/admin_providers.dart';

class AdminDealerScreen extends ConsumerWidget {
  const AdminDealerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingDealerRequestsProvider);
    final activeDealersAsync = ref.watch(allUsersProvider('dealer'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('업자 관리'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingDealerRequestsProvider);
          ref.invalidate(allUsersProvider('dealer'));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Section 1: Pending Requests ===
              _SectionHeader(
                icon: Icons.hourglass_top,
                title: '승인 대기',
                color: AppColors.warning,
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              pendingAsync.when(
                loading: () => const _LoadingBox(),
                error: (e, _) => _ErrorBox(
                  message: '대기 목록을 불러올 수 없습니다',
                  onRetry: () =>
                      ref.invalidate(pendingDealerRequestsProvider),
                ),
                data: (pending) {
                  if (pending.isEmpty) {
                    return const _EmptyBox(
                      icon: Icons.check_circle_outline,
                      message: '대기 중인 요청이 없습니다',
                    );
                  }
                  return Column(
                    children: pending.map((user) {
                      return _PendingDealerCard(
                        nickname: user.nickname,
                        email: user.email,
                        profileImageUrl: user.profileImageUrl,
                        dealerName: user.dealerName,
                        onApprove: () =>
                            _handleApprove(context, ref, user.uid),
                        onReject: () =>
                            _handleReject(context, ref, user.uid),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.paddingLG),

              // === Section 2: Active Dealers ===
              _SectionHeader(
                icon: Icons.store,
                title: '활성 업자',
                color: AppColors.success,
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              activeDealersAsync.when(
                loading: () => const _LoadingBox(),
                error: (e, _) => _ErrorBox(
                  message: '업자 목록을 불러올 수 없습니다',
                  onRetry: () =>
                      ref.invalidate(allUsersProvider('dealer')),
                ),
                data: (dealers) {
                  // Filter only approved dealers
                  final approved = dealers
                      .where((d) => d.dealerStatus == 'approved')
                      .toList();

                  if (approved.isEmpty) {
                    return const _EmptyBox(
                      icon: Icons.store_outlined,
                      message: '활성 업자가 없습니다',
                    );
                  }
                  return Column(
                    children: approved.map((dealer) {
                      return _ActiveDealerCard(
                        nickname: dealer.nickname,
                        email: dealer.email,
                        profileImageUrl: dealer.profileImageUrl,
                        dealerName: dealer.dealerName,
                        totalSales: dealer.totalSales,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleApprove(
      BuildContext context, WidgetRef ref, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('업자 승인'),
        content: const Text('이 유저를 업자로 승인하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('승인'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminRepositoryProvider).approveDealerRequest(userId);
        ref.invalidate(pendingDealerRequestsProvider);
        ref.invalidate(allUsersProvider('dealer'));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('업자가 승인되었습니다')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('오류: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleReject(
      BuildContext context, WidgetRef ref, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('업자 거절'),
        content: const Text('이 유저의 업자 요청을 거절하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('거절'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(adminRepositoryProvider).rejectDealerRequest(userId);
        ref.invalidate(pendingDealerRequestsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('요청이 거절되었습니다')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('오류: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.titleLarge),
      ],
    );
  }
}

class _PendingDealerCard extends StatelessWidget {
  final String nickname;
  final String email;
  final String? profileImageUrl;
  final String? dealerName;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingDealerCard({
    required this.nickname,
    required this.email,
    required this.profileImageUrl,
    required this.dealerName,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        side: BorderSide(
          color: AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: AppDimensions.avatarMD / 2,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nickname,
                          style: AppTypography.titleSmall),
                      const SizedBox(height: 2),
                      Text(email,
                          style: AppTypography.caption),
                      if (dealerName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '상호: $dealerName',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: onReject,
                    child: const Text('거절'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onApprove,
                    child: const Text('승인'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveDealerCard extends StatelessWidget {
  final String nickname;
  final String email;
  final String? profileImageUrl;
  final String? dealerName;
  final int totalSales;

  const _ActiveDealerCard({
    required this.nickname,
    required this.email,
    required this.profileImageUrl,
    required this.dealerName,
    required this.totalSales,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: AppDimensions.avatarSM / 2,
          backgroundImage: profileImageUrl != null
              ? NetworkImage(profileImageUrl!)
              : null,
          child: profileImageUrl == null
              ? const Icon(Icons.store, size: 20)
              : null,
        ),
        title: Text(
          dealerName ?? nickname,
          style: AppTypography.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email, style: AppTypography.caption),
            const SizedBox(height: 2),
            Text(
              '판매 ${totalSales}건',
              style: AppTypography.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.15),
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusSM),
          ),
          child: Text(
            '활성',
            style: AppTypography.caption.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline,
              color: AppColors.error, size: 28),
          const SizedBox(height: 8),
          Text(message, style: AppTypography.bodySmall),
          TextButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyBox({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 36),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
