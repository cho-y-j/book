import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/exchange_providers.dart';

class ExchangeHistoryScreen extends ConsumerWidget {
  const ExchangeHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(userMatchesProvider);
    final sentAsync = ref.watch(sentRequestsProvider);
    return DefaultTabController(length: 2, child: Scaffold(
      appBar: AppBar(title: const Text('교환 내역'), bottom: const TabBar(
        labelColor: AppColors.primary, unselectedLabelColor: AppColors.textSecondary, indicatorColor: AppColors.primary,
        tabs: [Tab(text: '매칭'), Tab(text: '보낸 요청')],
      )),
      body: TabBarView(children: [
        matchesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
          data: (matches) {
            if (matches.isEmpty) return Center(child: Text('매칭 내역이 없습니다', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)));
            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemCount: matches.length,
              itemBuilder: (_, i) {
                final m = matches[i];
                return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                  leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
                  title: Text('매칭 #${m.id.substring(0, 6)}', style: AppTypography.titleMedium),
                  subtitle: Text(m.status, style: AppTypography.caption),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.matchConfirmPath(m.id)),
                ));
              },
            );
          },
        ),
        sentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
          data: (requests) {
            if (requests.isEmpty) return Center(child: Text('보낸 요청이 없습니다', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)));
            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemCount: requests.length,
              itemBuilder: (_, i) {
                final r = requests[i];
                return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                  leading: const Icon(Icons.send, color: AppColors.secondary),
                  title: Text('요청 #${r.id.substring(0, 6)}', style: AppTypography.titleMedium),
                  subtitle: Text(r.status, style: AppTypography.caption),
                ));
              },
            );
          },
        ),
      ]),
    ));
  }
}
