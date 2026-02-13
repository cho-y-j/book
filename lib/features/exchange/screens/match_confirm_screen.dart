import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/exchange_providers.dart';

class MatchConfirmScreen extends ConsumerWidget {
  final String matchId;
  const MatchConfirmScreen({super.key, required this.matchId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingLG), child: FutureBuilder(
        future: ref.read(exchangeRepositoryProvider).getMatch(matchId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final match = snapshot.data;
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.celebration, size: 80, color: AppColors.accent),
            const SizedBox(height: 24),
            Text('매칭 성공!', style: AppTypography.headlineLarge.copyWith(color: AppColors.primary)),
            const SizedBox(height: 16),
            Text('두 분의 책이 연결되었어요', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const _BookPreview(label: '내 책'),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.swap_horiz, size: 32, color: AppColors.accent)),
              const _BookPreview(label: '상대 책'),
            ]),
            const SizedBox(height: 40),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () {
                if (match != null) {
                  context.push(AppRoutes.chatRoomPath(match.chatRoomId));
                }
              },
              child: const Text('채팅으로 이동'),
            )),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('나중에 하기')),
          ]);
        },
      ))),
    );
  }
}

class _BookPreview extends StatelessWidget {
  final String label;
  const _BookPreview({required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(width: 80, height: 110, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.book, color: AppColors.textSecondary)),
      const SizedBox(height: 8), Text(label, style: AppTypography.bodySmall),
    ]);
  }
}
