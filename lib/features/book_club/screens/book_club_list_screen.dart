import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/book_club_providers.dart';

class BookClubListScreen extends ConsumerWidget {
  const BookClubListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(bookClubsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('동네 책모임')),
      body: clubsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
        data: (clubs) {
          if (clubs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.groups_outlined, size: 80, color: AppColors.divider),
                const SizedBox(height: 16),
                Text('아직 책모임이 없어요', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('첫 번째 책모임을 만들어보세요!', style: AppTypography.bodySmall),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.createBookClub),
                  icon: const Icon(Icons.add),
                  label: const Text('모임 만들기'),
                ),
              ]),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(bookClubsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemCount: clubs.length,
              itemBuilder: (_, i) {
                final club = clubs[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    onTap: () => context.push(AppRoutes.bookClubDetailPath(club.id)),
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingMD),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.secondaryLight.withOpacity(0.3),
                            child: const Icon(Icons.groups, color: AppColors.secondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(club.name, style: AppTypography.titleMedium),
                            Text('${club.location} · ${club.memberUids.length}/${club.maxMembers}명', style: AppTypography.caption),
                          ])),
                        ]),
                        const SizedBox(height: 12),
                        Text(club.description, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (club.nextMeetingAt != null) ...[
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '다음 모임: ${club.nextMeetingAt!.month}/${club.nextMeetingAt!.day}',
                              style: AppTypography.caption,
                            ),
                          ]),
                        ],
                      ]),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createBookClub),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
