import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/admin_providers.dart';
import '../../../providers/user_providers.dart';

class AdminDealerScreen extends ConsumerWidget {
  const AdminDealerScreen({super.key});

  String _partnerTypeLabel(String? type) {
    switch (type) {
      case 'bookstore': return '중고서점';
      case 'donationOrg': return '기부단체';
      case 'library': return '도서관';
      default: return '파트너';
    }
  }

  Color _partnerTypeColor(String? type) {
    switch (type) {
      case 'bookstore': return AppColors.primary;
      case 'donationOrg': return AppColors.success;
      case 'library': return AppColors.info;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingPartnerRequestsProvider);
    final activePartnersAsync = ref.watch(allUsersProvider('partner'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('파트너 관리'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingPartnerRequestsProvider);
          ref.invalidate(allUsersProvider('partner'));
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
                      ref.invalidate(pendingPartnerRequestsProvider),
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
                      return _PendingPartnerCard(
                        nickname: user.nickname,
                        email: user.email,
                        profileImageUrl: user.profileImageUrl,
                        dealerName: user.dealerName,
                        partnerType: user.partnerType,
                        partnerTypeLabel: _partnerTypeLabel(user.partnerType),
                        partnerTypeColor: _partnerTypeColor(user.partnerType),
                        businessLicenseUrl: user.businessLicenseUrl,
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

              // === Section 2: Active Partners ===
              _SectionHeader(
                icon: Icons.store,
                title: '활성 파트너',
                color: AppColors.success,
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              activePartnersAsync.when(
                loading: () => const _LoadingBox(),
                error: (e, _) => _ErrorBox(
                  message: '파트너 목록을 불러올 수 없습니다',
                  onRetry: () =>
                      ref.invalidate(allUsersProvider('partner')),
                ),
                data: (partners) {
                  final approved = partners
                      .where((d) => d.dealerStatus == 'approved')
                      .toList();

                  if (approved.isEmpty) {
                    return const _EmptyBox(
                      icon: Icons.store_outlined,
                      message: '활성 파트너가 없습니다',
                    );
                  }
                  return Column(
                    children: approved.map((partner) {
                      return _ActivePartnerCard(
                        nickname: partner.nickname,
                        email: partner.email,
                        profileImageUrl: partner.profileImageUrl,
                        dealerName: partner.dealerName,
                        totalSales: partner.totalSales,
                        partnerTypeLabel: _partnerTypeLabel(partner.partnerType),
                        partnerTypeColor: _partnerTypeColor(partner.partnerType),
                        onEdit: () => _showEditPartnerDialog(context, ref, partner),
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

  void _showEditPartnerDialog(BuildContext context, WidgetRef ref, UserModel partner) {
    final nameCtrl = TextEditingController(text: partner.dealerName ?? '');
    String partnerType = partner.partnerType ?? 'bookstore';
    String status = partner.dealerStatus ?? 'approved';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('파트너 정보 수정'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          // 기본 정보 (읽기전용)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: partner.profileImageUrl != null ? NetworkImage(partner.profileImageUrl!) : null,
              child: partner.profileImageUrl == null ? const Icon(Icons.person) : null,
            ),
            title: Text(partner.nickname),
            subtitle: Text(partner.email),
          ),
          const Divider(),
          const SizedBox(height: 8),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '상호명')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: partnerType,
            decoration: const InputDecoration(labelText: '파트너 유형'),
            items: const [
              DropdownMenuItem(value: 'bookstore', child: Text('중고서점')),
              DropdownMenuItem(value: 'donationOrg', child: Text('기부단체')),
              DropdownMenuItem(value: 'library', child: Text('도서관')),
            ],
            onChanged: (v) => setDialogState(() => partnerType = v ?? 'bookstore'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(labelText: '상태'),
            items: const [
              DropdownMenuItem(value: 'approved', child: Text('승인 (활성)')),
              DropdownMenuItem(value: 'suspended', child: Text('정지')),
            ],
            onChanged: (v) => setDialogState(() => status = v ?? 'approved'),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(userRepositoryProvider);
              await repo.updateUser(partner.uid, {
                'dealerName': nameCtrl.text.trim(),
                'partnerType': partnerType,
                'dealerStatus': status,
              });
              ref.invalidate(allUsersProvider('partner'));
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('파트너 정보를 수정했습니다')),
                );
              }
            },
            child: const Text('저장'),
          ),
        ],
      )),
    );
  }

  Future<void> _handleApprove(
      BuildContext context, WidgetRef ref, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('파트너 승인'),
        content: const Text('이 유저를 파트너로 승인하시겠습니까?'),
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
        await ref.read(adminRepositoryProvider).approvePartnerRequest(userId);
        ref.invalidate(pendingPartnerRequestsProvider);
        ref.invalidate(allUsersProvider('partner'));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('파트너가 승인되었습니다')),
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
        title: const Text('파트너 거절'),
        content: const Text('이 유저의 파트너 요청을 거절하시겠습니까?'),
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
        await ref.read(adminRepositoryProvider).rejectPartnerRequest(userId);
        ref.invalidate(pendingPartnerRequestsProvider);
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

class _PendingPartnerCard extends StatelessWidget {
  final String nickname;
  final String email;
  final String? profileImageUrl;
  final String? dealerName;
  final String? partnerType;
  final String partnerTypeLabel;
  final Color partnerTypeColor;
  final String? businessLicenseUrl;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingPartnerCard({
    required this.nickname,
    required this.email,
    required this.profileImageUrl,
    required this.dealerName,
    required this.partnerType,
    required this.partnerTypeLabel,
    required this.partnerTypeColor,
    required this.businessLicenseUrl,
    required this.onApprove,
    required this.onReject,
  });

  void _showLicenseImage(BuildContext context) {
    if (businessLicenseUrl == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('사업자등록증'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx),
              ),
              automaticallyImplyLeading: false,
            ),
            InteractiveViewer(
              child: Image.network(
                businessLicenseUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 200,
                  child: Center(child: Text('이미지를 불러올 수 없습니다')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                      Row(
                        children: [
                          Text(nickname, style: AppTypography.titleSmall),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: partnerTypeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              partnerTypeLabel,
                              style: AppTypography.caption.copyWith(
                                color: partnerTypeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(email, style: AppTypography.caption),
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

            // 사업자등록증 확인
            if (businessLicenseUrl != null)
              GestureDetector(
                onTap: () => _showLicenseImage(context),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM - 1),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          businessLicenseUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, size: 32, color: Colors.grey),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.info,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text('사업자등록증 확인', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, size: 18, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      '사업자등록증 미첨부',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),

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

class _ActivePartnerCard extends StatelessWidget {
  final String nickname;
  final String email;
  final String? profileImageUrl;
  final String? dealerName;
  final int totalSales;
  final String partnerTypeLabel;
  final Color partnerTypeColor;
  final VoidCallback onEdit;

  const _ActivePartnerCard({
    required this.nickname,
    required this.email,
    required this.profileImageUrl,
    required this.dealerName,
    required this.totalSales,
    required this.partnerTypeLabel,
    required this.partnerTypeColor,
    required this.onEdit,
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
        title: Row(
          children: [
            Flexible(child: Text(dealerName ?? nickname, style: AppTypography.titleSmall)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: partnerTypeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                partnerTypeLabel,
                style: AppTypography.caption.copyWith(
                  color: partnerTypeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              tooltip: '수정',
              onPressed: onEdit,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Text(
                '활성',
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
