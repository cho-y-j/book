import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/user_providers.dart';
import '../../../providers/admin_providers.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('마이'), actions: [IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.push(AppRoutes.settings))]),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('프로필을 불러올 수 없습니다', style: AppTypography.bodyMedium)),
        data: (user) {
          final nickname = user?.nickname ?? '닉네임';
          final location = user?.primaryLocation ?? '지역 미설정';
          final temp = user?.bookTemperature.toStringAsFixed(1) ?? '36.5';
          final exchanges = user?.totalExchanges ?? 0;
          final level = user?.level ?? 1;
          return SingleChildScrollView(child: Column(children: [
            Padding(padding: const EdgeInsets.all(AppDimensions.paddingLG), child: Column(children: [
              GestureDetector(
                onTap: () => context.push(AppRoutes.editProfile),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: user?.profileImageUrl != null ? NetworkImage(user!.profileImageUrl!) : null,
                  child: user?.profileImageUrl == null ? const Icon(Icons.person, size: 40) : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(nickname, style: AppTypography.headlineSmall),
              const SizedBox(height: 4),
              Text(location, style: AppTypography.bodySmall),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _StatItem(label: '온도', value: '$temp°C'),
                  _StatItem(label: '교환', value: '${exchanges}회'),
                  _StatItem(label: '레벨', value: 'Lv.$level'),
                ]),
              ),
            ])),
            const Divider(height: 1),
            _MenuTile(icon: Icons.shelves, title: '내 책장', onTap: () => context.push(AppRoutes.myBookshelf)),
            _MenuTile(icon: Icons.bookmark_outline, title: '위시리스트', onTap: () => context.push(AppRoutes.wishlist)),
            _MenuTile(icon: Icons.swap_horiz, title: '교환 내역', onTap: () => context.push(AppRoutes.exchangeHistory)),
            _MenuTile(icon: Icons.star_outline, title: '받은 후기', onTap: () => context.push(AppRoutes.receivedReviews)),
            _MenuTile(icon: Icons.mail_outline, title: '받은 교환 요청', onTap: () => context.push(AppRoutes.incomingRequests)),
            _MenuTile(icon: Icons.shopping_bag_outlined, title: '받은 구매 요청', onTap: () => context.push(AppRoutes.incomingPurchaseRequests)),
            _MenuTile(icon: Icons.groups_outlined, title: '동네 책모임', onTap: () => context.push(AppRoutes.bookClubList)),
            _MenuTile(icon: Icons.bar_chart, title: '나의 통계', onTap: () => context.push(AppRoutes.myStats)),
            _MenuTile(icon: Icons.emoji_events_outlined, title: '랭킹', onTap: () => context.push(AppRoutes.ranking)),
            // 업자 메뉴
            if (user?.role == 'user')
              _MenuTile(icon: Icons.store_outlined, title: '업자 신청', onTap: () => context.push(AppRoutes.dealerRequest)),
            if (user?.role == 'dealer' && user?.dealerStatus == 'pending')
              _MenuTile(icon: Icons.hourglass_top, title: '업자 승인 대기 중', onTap: () {}),
            if (user?.role == 'dealer' && user?.dealerStatus == 'approved')
              _MenuTile(icon: Icons.store, title: '업자 (승인됨)', onTap: () {}),
            // 관리자 메뉴 (admin만 표시)
            if (ref.watch(isAdminProvider))
              _MenuTile(icon: Icons.admin_panel_settings, title: '관리자 대시보드', onTap: () => context.push(AppRoutes.adminDashboard)),
          ]));
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label; final String value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: AppTypography.titleLarge.copyWith(color: AppColors.primary)),
      const SizedBox(height: 4), Text(label, style: AppTypography.caption),
    ]);
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon, color: AppColors.textSecondary), title: Text(title, style: AppTypography.bodyLarge), trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary), onTap: onTap);
  }
}
