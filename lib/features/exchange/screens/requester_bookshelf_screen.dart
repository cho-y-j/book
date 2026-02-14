import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/auto_greeting_helper.dart';
import '../../../data/models/match_model.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/exchange_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/chat_providers.dart';

class RequesterBookshelfScreen extends ConsumerWidget {
  final String requesterUid;
  final String? exchangeRequestId;
  final String? targetBookId;
  const RequesterBookshelfScreen({
    super.key,
    required this.requesterUid,
    this.exchangeRequestId,
    this.targetBookId,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(userBooksProvider(requesterUid));
    return Scaffold(
      appBar: AppBar(title: const Text('요청자 책장')),
      body: booksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
        data: (books) {
          if (books.isEmpty) return Center(child: Text('등록된 책이 없습니다', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)));
          return GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.65, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: books.length,
            itemBuilder: (_, i) => Card(child: Column(children: [
              Expanded(child: Container(decoration: BoxDecoration(color: AppColors.divider, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: const Center(child: Icon(Icons.book, color: AppColors.textSecondary)))),
              Padding(padding: const EdgeInsets.all(8), child: Column(children: [
                Text(books[i].title, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () async {
                    final user = ref.read(currentUserProvider);
                    if (user == null) return;

                    // 1. 채팅방 생성 + 자동 인사말
                    final greeting = AutoGreetingHelper.getGreeting(
                      transactionType: 'exchange',
                      bookTitle: books[i].title,
                    );
                    final chatRoomId = await ref.read(chatRepositoryProvider).createTransactionChatRoom(
                      participants: [user.uid, requesterUid],
                      transactionType: 'exchange',
                      bookTitle: books[i].title,
                      bookId: books[i].id,
                      senderUid: user.uid,
                      autoGreetingMessage: greeting,
                    );

                    // 2. 매치 생성
                    final match = MatchModel(
                      id: '',
                      exchangeRequestId: exchangeRequestId ?? '',
                      userAUid: user.uid,
                      userBUid: requesterUid,
                      bookAId: targetBookId ?? '',
                      bookBId: books[i].id,
                      exchangeMethod: 'local',
                      chatRoomId: chatRoomId,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(exchangeRepositoryProvider).createMatch(match);

                    // 3. 교환 요청 상태 업데이트
                    if (exchangeRequestId != null) {
                      await ref.read(exchangeRepositoryProvider).updateRequestStatus(exchangeRequestId!, 'matched');
                    }

                    // 4. 채팅방으로 이동
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('매칭 완료! 채팅방으로 이동합니다')));
                      context.push(AppRoutes.chatRoomPath(chatRoomId));
                    }
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4), textStyle: const TextStyle(fontSize: 11)),
                  child: const Text('이 책과 교환'),
                )),
              ])),
            ])),
          );
        },
      ),
    );
  }
}
