import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/book_club_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/user_providers.dart';

class BookClubDetailScreen extends ConsumerStatefulWidget {
  final String clubId;
  const BookClubDetailScreen({super.key, required this.clubId});
  @override
  ConsumerState<BookClubDetailScreen> createState() => _BookClubDetailScreenState();
}

class _BookClubDetailScreenState extends ConsumerState<BookClubDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String clubId) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentUserProvider);
    final profile = ref.read(currentUserProfileProvider).value;
    if (user == null) return;

    ref.read(bookClubRepositoryProvider).sendMessage(
      clubId,
      senderUid: user.uid,
      senderNickname: profile?.nickname ?? '사용자',
      senderProfileImageUrl: profile?.profileImageUrl,
      content: text,
    );
    _messageController.clear();

    // 스크롤을 맨 아래로
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _setNextMeeting(String clubId) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 14, minute: 0));
    final meeting = time != null
        ? DateTime(date.year, date.month, date.day, time.hour, time.minute)
        : date;

    await ref.read(bookClubRepositoryProvider).updateClub(clubId, {
      'nextMeetingAt': Timestamp.fromDate(meeting),
    });
    ref.invalidate(bookClubStreamProvider(clubId));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모임 일정이 설정되었습니다'), backgroundColor: AppColors.success));
    }
  }

  Future<void> _deleteClub(String clubId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('모임 삭제'),
        content: const Text('정말 이 모임을 삭제하시겠습니까?\n모든 채팅 내역도 함께 삭제됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('삭제', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(bookClubRepositoryProvider).deleteBookClub(clubId);
    ref.invalidate(bookClubsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모임이 삭제되었습니다')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(bookClubStreamProvider(widget.clubId));
    final uid = ref.watch(currentUserProvider)?.uid;

    return clubAsync.when(
      loading: () => Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('불러오기 실패: $e'))),
      data: (club) {
        if (club == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('존재하지 않는 모임입니다')));
        }

        final isMember = uid != null && club.memberUids.contains(uid);
        final isCreator = uid == club.creatorUid;

        return Scaffold(
          appBar: AppBar(
            title: Text(club.name),
            actions: [
              if (isCreator)
                PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'meeting', child: Text('모임 일정 설정')),
                    PopupMenuItem(value: 'delete', child: Text('모임 삭제', style: TextStyle(color: AppColors.error))),
                  ],
                  onSelected: (v) {
                    if (v == 'meeting') _setNextMeeting(widget.clubId);
                    if (v == 'delete') _deleteClub(widget.clubId);
                  },
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '정보'),
                Tab(text: '채팅'),
                Tab(text: '멤버'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _InfoTab(club: club, isMember: isMember, isCreator: isCreator, uid: uid, clubId: widget.clubId),
              isMember
                  ? _ChatTab(
                      clubId: widget.clubId,
                      uid: uid!,
                      messageController: _messageController,
                      scrollController: _scrollController,
                      onSend: () => _sendMessage(widget.clubId),
                    )
                  : Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.lock_outline, size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text('모임에 가입하면 채팅에 참여할 수 있어요', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      ]),
                    ),
              _MembersTab(memberUids: club.memberUids, creatorUid: club.creatorUid),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 정보 탭
// ---------------------------------------------------------------------------
class _InfoTab extends ConsumerWidget {
  final dynamic club;
  final bool isMember;
  final bool isCreator;
  final String? uid;
  final String clubId;

  const _InfoTab({required this.club, required this.isMember, required this.isCreator, this.uid, required this.clubId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 모임 정보 카드
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.groups, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(club.name, style: AppTypography.headlineSmall)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(club.location.isEmpty ? '지역 미설정' : club.location, style: AppTypography.bodySmall),
                const SizedBox(width: 16),
                Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${club.memberUids.length}/${club.maxMembers}명', style: AppTypography.bodySmall),
              ]),
              if (club.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(club.description, style: AppTypography.bodyMedium),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 16),

        // 다음 모임 일정
        Card(
          child: ListTile(
            leading: Icon(Icons.calendar_today, color: club.nextMeetingAt != null ? AppColors.primary : AppColors.textSecondary),
            title: const Text('다음 모임'),
            subtitle: Text(
              club.nextMeetingAt != null
                  ? '${club.nextMeetingAt!.year}년 ${club.nextMeetingAt!.month}월 ${club.nextMeetingAt!.day}일 ${club.nextMeetingAt!.hour}:${club.nextMeetingAt!.minute.toString().padLeft(2, '0')}'
                  : '일정이 아직 없어요',
              style: TextStyle(color: club.nextMeetingAt != null ? AppColors.textPrimary : AppColors.textSecondary),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 가입 / 탈퇴 버튼
        if (!isMember && club.memberUids.length < club.maxMembers)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.group_add),
              label: const Text('모임 가입'),
              onPressed: () async {
                if (uid == null) return;
                await ref.read(bookClubRepositoryProvider).joinBookClub(clubId, uid!);
                ref.invalidate(bookClubStreamProvider(clubId));
                ref.invalidate(bookClubsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('모임에 참여했습니다!'), backgroundColor: AppColors.success),
                  );
                }
              },
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
                  await ref.read(bookClubRepositoryProvider).leaveBookClub(clubId, uid!);
                  ref.invalidate(bookClubStreamProvider(clubId));
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
    );
  }
}

// ---------------------------------------------------------------------------
// 채팅 탭
// ---------------------------------------------------------------------------
class _ChatTab extends ConsumerWidget {
  final String clubId;
  final String uid;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final VoidCallback onSend;

  const _ChatTab({
    required this.clubId,
    required this.uid,
    required this.messageController,
    required this.scrollController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(clubMessagesProvider(clubId));

    return Column(children: [
      Expanded(
        child: messagesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('메시지를 불러올 수 없습니다', style: AppTypography.bodyMedium)),
          data: (messages) {
            if (messages.isEmpty) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text('첫 메시지를 보내보세요!', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ]),
              );
            }

            // 새 메시지가 오면 자동 스크롤
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.jumpTo(scrollController.position.maxScrollExtent);
              }
            });

            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(AppDimensions.paddingSM),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                final isMe = msg['senderUid'] == uid;
                final nickname = msg['senderNickname'] ?? '사용자';
                final profileUrl = msg['senderProfileImageUrl'] as String?;
                final content = msg['content'] ?? '';
                final createdAt = (msg['createdAt'] as Timestamp?)?.toDate();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: profileUrl != null ? NetworkImage(profileUrl) : null,
                          child: profileUrl == null ? Text(nickname[0], style: const TextStyle(fontSize: 12)) : null,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2, left: 4),
                                child: Text(nickname, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                              ),
                              child: Text(content, style: AppTypography.bodyMedium.copyWith(color: isMe ? Colors.white : AppColors.textPrimary)),
                            ),
                            if (createdAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                                child: Text(
                                  '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isMe) const SizedBox(width: 8),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      // 메시지 입력 바
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: '메시지 입력',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: onSend,
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------
// 멤버 탭
// ---------------------------------------------------------------------------
class _MembersTab extends ConsumerWidget {
  final List<String> memberUids;
  final String creatorUid;

  const _MembersTab({required this.memberUids, required this.creatorUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(clubMembersProvider(memberUids));

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('멤버 정보를 불러올 수 없습니다', style: AppTypography.bodyMedium)),
      data: (members) {
        // 모임장을 먼저 표시
        final sorted = [...members];
        sorted.sort((a, b) {
          if (a.uid == creatorUid) return -1;
          if (b.uid == creatorUid) return 1;
          return 0;
        });

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            final member = sorted[i];
            final isCreator = member.uid == creatorUid;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: member.profileImageUrl != null ? NetworkImage(member.profileImageUrl!) : null,
                  child: member.profileImageUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Row(children: [
                  Text(member.nickname, style: AppTypography.titleMedium),
                  if (isCreator) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('모임장', style: AppTypography.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ]),
                subtitle: Text(
                  '${Formatters.temperature(member.bookTemperature)} · ${member.primaryLocation.isEmpty ? "지역 미설정" : member.primaryLocation}',
                  style: AppTypography.bodySmall,
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () => context.push(AppRoutes.userProfilePath(member.uid)),
              ),
            );
          },
        );
      },
    );
  }
}
