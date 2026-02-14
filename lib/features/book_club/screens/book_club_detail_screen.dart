import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/book_club_providers.dart';
import '../../../providers/auth_providers.dart';

class BookClubDetailScreen extends ConsumerWidget {
  final String clubId;
  const BookClubDetailScreen({super.key, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(bookClubDetailProvider(clubId));
    final uid = ref.watch(currentUserProvider)?.uid;

    return clubAsync.when(
      loading: () => Scaffold(appBar: AppBar(title: const Text('책모임 상세')), body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(title: const Text('책모임 상세')), body: Center(child: Text('불러오기 실패: $e'))),
      data: (club) {
        if (club == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('존재하지 않는 모임입니다')));
        }

        final isMember = uid != null && club.memberUids.contains(uid);
        final isCreator = uid == club.creatorUid;

        return Scaffold(
          appBar: AppBar(title: Text(club.name)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(club.name, style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              Text('${club.location} · ${club.memberUids.length}/${club.maxMembers}명 참여', style: AppTypography.bodySmall),
              const SizedBox(height: 16),
              Text(club.description, style: AppTypography.bodyMedium),
              if (club.nextMeetingAt != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                    title: const Text('다음 모임'),
                    subtitle: Text('${club.nextMeetingAt!.year}/${club.nextMeetingAt!.month}/${club.nextMeetingAt!.day}'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('멤버 (${club.memberUids.length})', style: AppTypography.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: club.memberUids.asMap().entries.map((e) => Column(children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: e.key == 0 ? AppColors.primaryLight : AppColors.divider,
                    child: Text('${e.key + 1}', style: TextStyle(color: e.key == 0 ? Colors.white : AppColors.textSecondary)),
                  ),
                  const SizedBox(height: 4),
                  Text(e.key == 0 ? '모임장' : '멤버${e.key + 1}', style: AppTypography.caption),
                ])).toList(),
              ),
              const SizedBox(height: 32),
              if (!isMember && club.memberUids.length < club.maxMembers)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (uid == null) return;
                      await ref.read(bookClubRepositoryProvider).joinBookClub(clubId, uid);
                      ref.invalidate(bookClubDetailProvider(clubId));
                      ref.invalidate(bookClubsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('모임에 참여했습니다!'), backgroundColor: AppColors.success),
                        );
                      }
                    },
                    child: const Text('참여 신청'),
                  ),
                ),
              if (isMember && !isCreator)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      if (uid == null) return;
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('모임 탈퇴'),
                          content: const Text('정말 탈퇴하시겠습니까?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('탈퇴')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref.read(bookClubRepositoryProvider).leaveBookClub(clubId, uid);
                        ref.invalidate(bookClubDetailProvider(clubId));
                        ref.invalidate(bookClubsProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모임에서 탈퇴했습니다')));
                        }
                      }
                    },
                    child: const Text('탈퇴하기'),
                  ),
                ),
              if (isMember)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(child: Text('참여 중인 모임입니다', style: AppTypography.bodySmall.copyWith(color: AppColors.success))),
                ),
            ]),
          ),
        );
      },
    );
  }
}
