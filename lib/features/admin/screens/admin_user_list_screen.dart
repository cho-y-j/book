import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/admin_providers.dart';

class AdminUserListScreen extends ConsumerStatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  ConsumerState<AdminUserListScreen> createState() =>
      _AdminUserListScreenState();
}

class _AdminUserListScreenState extends ConsumerState<AdminUserListScreen> {
  String? _selectedRole;

  static const _roleFilters = <String?, String>{
    null: '전체',
    'user': '일반',
    'dealer': '업자',
    'admin': '관리자',
  };

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider(_selectedRole));

    return Scaffold(
      appBar: AppBar(
        title: const Text('유저 관리'),
      ),
      body: Column(
        children: [
          // === Role Filter Chips ===
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMD,
                vertical: AppDimensions.paddingSM,
              ),
              children: _roleFilters.entries.map((entry) {
                final isSelected = _selectedRole == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: Colors.white,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedRole = entry.key);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // === User List ===
          Expanded(
            child: usersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 8),
                    Text('유저를 불러올 수 없습니다',
                        style: AppTypography.bodyMedium),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref
                          .invalidate(allUsersProvider(_selectedRole)),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline,
                            size: 64, color: AppColors.divider),
                        const SizedBox(height: 16),
                        Text(
                          '해당 유저가 없습니다',
                          style: AppTypography.titleMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(allUsersProvider(_selectedRole)),
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.all(AppDimensions.paddingMD),
                    itemCount: users.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.paddingSM),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _UserListItem(
                        nickname: user.nickname,
                        email: user.email,
                        role: user.role,
                        status: user.status,
                        profileImageUrl: user.profileImageUrl,
                        onTap: () => context.push(
                          AppRoutes.adminUserDetailPath(user.uid),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final String nickname;
  final String email;
  final String role;
  final String status;
  final String? profileImageUrl;
  final VoidCallback onTap;

  const _UserListItem({
    required this.nickname,
    required this.email,
    required this.role,
    required this.status,
    required this.profileImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
              ? const Icon(Icons.person, size: 20)
              : null,
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                nickname,
                style: AppTypography.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _RoleBadge(role: role),
          ],
        ),
        subtitle: Text(
          email,
          style: AppTypography.caption,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusBadge(status: status),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (role) {
      'admin' => ('관리자', AppColors.error),
      'dealer' => ('업자', AppColors.warning),
      _ => ('일반', AppColors.info),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.error)
            .withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Text(
        isActive ? '활성' : '정지',
        style: AppTypography.caption.copyWith(
          color: isActive ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
