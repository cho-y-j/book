import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 대시보드'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminStatsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Stats Grid ===
              Text('통계 요약', style: AppTypography.titleLarge),
              const SizedBox(height: AppDimensions.paddingSM),
              statsAsync.when(
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 32),
                      const SizedBox(height: 8),
                      Text('통계를 불러올 수 없습니다',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.error)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(adminStatsProvider),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
                data: (stats) => GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppDimensions.paddingSM,
                  mainAxisSpacing: AppDimensions.paddingSM,
                  childAspectRatio: 1.0,
                  children: [
                    _StatCard(
                      icon: Icons.people,
                      value: stats['totalUsers'] ?? 0,
                      label: '전체 유저',
                      color: AppColors.info,
                    ),
                    _StatCard(
                      icon: Icons.menu_book,
                      value: stats['totalBooks'] ?? 0,
                      label: '전체 책',
                      color: AppColors.primary,
                    ),
                    _StatCard(
                      icon: Icons.swap_horiz,
                      value: stats['totalExchanges'] ?? 0,
                      label: '교환 완료',
                      color: AppColors.secondary,
                    ),
                    _StatCard(
                      icon: Icons.shopping_bag,
                      value: stats['totalSales'] ?? 0,
                      label: '판매 완료',
                      color: AppColors.success,
                    ),
                    _StatCard(
                      icon: Icons.store,
                      value: stats['totalDealers'] ?? 0,
                      label: '업자 수',
                      color: AppColors.warning,
                    ),
                    _StatCard(
                      icon: Icons.flag,
                      value: stats['pendingReports'] ?? 0,
                      label: '대기 신고',
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.paddingLG),

              // === Navigation Section ===
              Text('관리 메뉴', style: AppTypography.titleLarge),
              const SizedBox(height: AppDimensions.paddingSM),
              _NavigationTile(
                icon: Icons.people_outline,
                title: '유저 관리',
                subtitle: '유저 목록 조회, 역할 변경, 정지 관리',
                onTap: () => context.push('/admin/users'),
              ),
              _NavigationTile(
                icon: Icons.store_outlined,
                title: '업자 관리',
                subtitle: '업자 승인/거절, 활성 업자 관리',
                onTap: () => context.push('/admin/dealers'),
              ),
              _NavigationTile(
                icon: Icons.menu_book_outlined,
                title: '책 관리',
                subtitle: '등록된 책 관리, 부적절 콘텐츠 삭제',
                onTap: () => context.push('/admin/books'),
              ),
              _NavigationTile(
                icon: Icons.flag_outlined,
                title: '신고 관리',
                subtitle: '신고 접수 및 처리',
                onTap: () => context.push('/admin/reports'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingSM),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: AppDimensions.iconLG),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: AppTypography.headlineSmall.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTypography.titleSmall),
        subtitle: Text(subtitle, style: AppTypography.caption),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
