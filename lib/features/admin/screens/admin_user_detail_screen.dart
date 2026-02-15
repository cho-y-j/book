import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/admin_providers.dart';

class AdminUserDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<AdminUserDetailScreen> createState() =>
      _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState
    extends ConsumerState<AdminUserDetailScreen> {
  String? _selectedRole;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(adminUserDetailProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('유저 상세'),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 8),
              Text('유저 정보를 불러올 수 없습니다',
                  style: AppTypography.bodyMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(
                    adminUserDetailProvider(widget.userId)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('존재하지 않는 유저입니다'),
            );
          }

          _selectedRole ??= user.role;
          final isSuspended = user.status == 'suspended';
          final dateFormat = DateFormat('yyyy.MM.dd');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Column(
              children: [
                // === Profile Header ===
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(AppDimensions.paddingLG),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: AppDimensions.avatarLG / 2,
                        backgroundImage: user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                        child: user.profileImageUrl == null
                            ? const Icon(Icons.person, size: 36)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(user.nickname,
                          style: AppTypography.headlineSmall),
                      const SizedBox(height: 4),
                      Text(user.email, style: AppTypography.bodySmall),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _InfoBadge(
                            label: '역할',
                            value: _roleLabel(user.role),
                            color: _roleColor(user.role),
                          ),
                          const SizedBox(width: 8),
                          _InfoBadge(
                            label: '상태',
                            value: isSuspended ? '정지' : '활성',
                            color: isSuspended
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingMD),

                // === Stats Section ===
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(AppDimensions.paddingMD),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('활동 정보',
                          style: AppTypography.titleMedium),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: '책 온도',
                        value:
                            '${user.bookTemperature.toStringAsFixed(1)}°C',
                      ),
                      _DetailRow(
                        label: '교환 완료',
                        value: '${user.totalExchanges}회',
                      ),
                      _DetailRow(
                        label: '판매 완료',
                        value: '${user.totalSales}회',
                      ),
                      _DetailRow(
                        label: '레벨',
                        value: 'Lv.${user.level}',
                      ),
                      _DetailRow(
                        label: '포인트',
                        value: '${user.points}P',
                      ),
                      _DetailRow(
                        label: '가입일',
                        value: dateFormat.format(user.createdAt),
                      ),
                      _DetailRow(
                        label: '마지막 활동',
                        value: dateFormat.format(user.lastActiveAt),
                      ),
                      if (user.dealerName != null)
                        _DetailRow(
                          label: '파트너 상호',
                          value: user.dealerName!,
                        ),
                      if (user.dealerStatus != null)
                        _DetailRow(
                          label: '파트너 상태',
                          value: _dealerStatusLabel(user.dealerStatus!),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingMD),

                // === Management Actions ===
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(AppDimensions.paddingMD),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('관리 액션',
                          style: AppTypography.titleMedium),
                      const SizedBox(height: 16),

                      // Suspend / Unsuspend
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Icon(
                            isSuspended
                                ? Icons.check_circle_outline
                                : Icons.block,
                            color: isSuspended
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          label: Text(
                            isSuspended ? '정지 해제' : '정지',
                            style: TextStyle(
                              color: isSuspended
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isSuspended
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                          onPressed: _isSaving
                              ? null
                              : () => _toggleSuspension(
                                  user.uid, isSuspended),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Role Dropdown
                      Text('역할 변경',
                          style: AppTypography.labelLarge),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSM),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                  value: 'user',
                                  child: Text('일반 유저')),
                              DropdownMenuItem(
                                  value: 'partner',
                                  child: Text('파트너')),
                              DropdownMenuItem(
                                  value: 'admin',
                                  child: Text('관리자')),
                            ],
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() =>
                                          _selectedRole = value);
                                    }
                                  },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSM),
                            ),
                          ),
                          onPressed: _isSaving
                              ? null
                              : () =>
                                  _saveChanges(user.uid, user.role),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('저장'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleSuspension(
      String uid, bool currentlySuspended) async {
    setState(() => _isSaving = true);
    try {
      final newStatus = currentlySuspended ? 'active' : 'suspended';
      if (newStatus == 'suspended') {
        await ref.read(adminRepositoryProvider).suspendUser(uid);
      } else {
        await ref.read(adminRepositoryProvider).unsuspendUser(uid);
      }
      ref.invalidate(adminUserDetailProvider(widget.userId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                currentlySuspended ? '정지가 해제되었습니다' : '유저가 정지되었습니다'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveChanges(String uid, String currentRole) async {
    if (_selectedRole == currentRole) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('변경된 내용이 없습니다')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(adminRepositoryProvider).updateUserRole(uid, _selectedRole!);
      ref.invalidate(adminUserDetailProvider(widget.userId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('역할이 변경되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _roleLabel(String role) => switch (role) {
        'admin' => '관리자',
        'partner' => '파트너',
        _ => '일반',
      };

  Color _roleColor(String role) => switch (role) {
        'admin' => AppColors.error,
        'partner' => AppColors.warning,
        _ => AppColors.info,
      };

  String _dealerStatusLabel(String status) => switch (status) {
        'pending' => '승인 대기',
        'approved' => '승인됨',
        'suspended' => '정지됨',
        'rejected' => '거절됨',
        _ => status,
      };
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTypography.caption.copyWith(color: color),
          ),
          Text(
            value,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}
