import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class BookClubListScreen extends ConsumerWidget {
  const BookClubListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('동네 책모임')),
      body: ListView.builder(padding: const EdgeInsets.all(AppDimensions.paddingMD), itemCount: 4, itemBuilder: (_, i) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 24, backgroundColor: AppColors.secondaryLight.withOpacity(0.3), child: const Icon(Icons.groups, color: AppColors.secondary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('책모임 ${i + 1}', style: AppTypography.titleMedium),
              Text('강남구 · ${4 + i}명 참여', style: AppTypography.caption),
            ])),
          ]),
          const SizedBox(height: 12),
          Text('함께 읽고 토론하는 즐거움을 나눠요', style: AppTypography.bodySmall),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.book, size: 14, color: AppColors.textSecondary), const SizedBox(width: 4),
            Text('현재 읽는 책: 데미안', style: AppTypography.caption),
            const Spacer(),
            TextButton(onPressed: () => context.push(AppRoutes.bookClubDetailPath('club_${i + 1}')), child: Text('참여하기', style: TextStyle(color: AppColors.primary))),
          ]),
        ])),
      )),
      floatingActionButton: FloatingActionButton(onPressed: () => context.push(AppRoutes.createBookClub), backgroundColor: AppColors.primary, child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}
