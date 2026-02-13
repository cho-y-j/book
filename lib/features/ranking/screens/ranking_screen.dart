import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(length: 3, child: Scaffold(
      appBar: AppBar(title: const Text('랭킹'), bottom: const TabBar(
        labelColor: AppColors.primary, unselectedLabelColor: AppColors.textSecondary, indicatorColor: AppColors.primary,
        tabs: [Tab(text: '교환왕'), Tab(text: '인기 책'), Tab(text: '희귀 책')],
      )),
      body: TabBarView(children: [
        ListView.builder(padding: const EdgeInsets.all(AppDimensions.paddingMD), itemCount: 10, itemBuilder: (_, i) => ListTile(
          leading: CircleAvatar(backgroundColor: i < 3 ? AppColors.primaryLight : AppColors.divider, child: Text('${i + 1}', style: TextStyle(color: i < 3 ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold))),
          title: Text('사용자 ${i + 1}', style: AppTypography.titleMedium),
          subtitle: Text('${50 - i * 3}회 교환', style: AppTypography.caption),
          trailing: i == 0 ? const Text('👑', style: TextStyle(fontSize: 24)) : null,
        )),
        ListView.builder(padding: const EdgeInsets.all(AppDimensions.paddingMD), itemCount: 10, itemBuilder: (_, i) => ListTile(
          leading: Container(width: 45, height: 60, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4)), child: Center(child: Text('${i + 1}', style: AppTypography.labelLarge))),
          title: Text('인기 책 ${i + 1}', style: AppTypography.titleMedium),
          subtitle: Text('교환 ${30 - i * 2}회', style: AppTypography.caption),
        )),
        ListView.builder(padding: const EdgeInsets.all(AppDimensions.paddingMD), itemCount: 10, itemBuilder: (_, i) => ListTile(
          leading: Container(width: 45, height: 60, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4)), child: Center(child: Text('${i + 1}', style: AppTypography.labelLarge))),
          title: Text('희귀 책 ${i + 1}', style: AppTypography.titleMedium),
          subtitle: Text('난이도: 높음 🔴', style: AppTypography.caption.copyWith(color: AppColors.error)),
        )),
      ]),
    ));
  }
}
