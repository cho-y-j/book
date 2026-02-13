import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class BookClubDetailScreen extends ConsumerWidget {
  final String clubId;
  const BookClubDetailScreen({super.key, required this.clubId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('책모임 상세')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(AppDimensions.paddingLG), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('독서토론 모임', style: AppTypography.headlineSmall),
        const SizedBox(height: 8),
        Text('강남구 · 8명 참여 · 최대 20명', style: AppTypography.bodySmall),
        const SizedBox(height: 16),
        Text('함께 읽고 토론하는 즐거움을 나눠요. 매주 토요일 오전 10시에 만납니다.', style: AppTypography.bodyMedium),
        const SizedBox(height: 24),
        Text('현재 읽는 책', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        Card(child: ListTile(leading: Container(width: 45, height: 60, color: AppColors.divider), title: const Text('데미안'), subtitle: const Text('헤르만 헤세'))),
        const SizedBox(height: 24),
        Text('멤버', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 12, children: List.generate(8, (i) => Column(children: [
          CircleAvatar(radius: 24, backgroundColor: AppColors.primaryLight.withOpacity(0.3), child: Text('${i + 1}', style: const TextStyle(color: AppColors.primary))),
          const SizedBox(height: 4), Text('멤버${i + 1}', style: AppTypography.caption),
        ]))),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, child: const Text('참여 신청'))),
      ])),
    );
  }
}
