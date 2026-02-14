import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../data/models/donation_model.dart';
import '../../../providers/donation_providers.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/chat_providers.dart';
import '../../../core/utils/auto_greeting_helper.dart';

class DonationScreen extends ConsumerStatefulWidget {
  final String organizationId;
  const DonationScreen({super.key, required this.organizationId});
  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  final _messageController = TextEditingController();
  String? _selectedBookId;
  String? _selectedBookTitle;
  bool _isLoading = false;

  @override
  void dispose() { _messageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final orgsAsync = ref.watch(organizationsStreamProvider);
    final currentUser = ref.watch(currentUserProvider);
    final userBooksAsync = currentUser != null ? ref.watch(userBooksProvider(currentUser.uid)) : null;

    final org = orgsAsync.valueOrNull?.where((o) => o.id == widget.organizationId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('책 기증하기')),
      body: Padding(padding: const EdgeInsets.all(AppDimensions.paddingLG), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Organization info card
        if (org != null) Card(child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: const Icon(Icons.business, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(org.name, style: AppTypography.titleMedium),
            Text(org.address, style: AppTypography.bodySmall),
          ])),
        ]))),
        const SizedBox(height: 16),

        // Book selection
        Text('기증할 책 선택', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        if (userBooksAsync != null)
          userBooksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text('내 책장을 불러올 수 없습니다'),
            data: (books) {
              final availableBooks = books.where((b) => b.status == 'available').toList();
              if (availableBooks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('기증 가능한 책이 없습니다. 먼저 책을 등록해주세요.'),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    hint: const Text('책을 선택하세요'),
                    value: _selectedBookId,
                    items: availableBooks.map((b) => DropdownMenuItem(
                      value: b.id,
                      child: Text(b.title, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) {
                      final book = availableBooks.firstWhere((b) => b.id == v);
                      setState(() { _selectedBookId = v; _selectedBookTitle = book.title; });
                    },
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),

        Text('메시지 (선택)', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          decoration: const InputDecoration(hintText: '기증 메시지를 적어주세요'),
          maxLines: 3,
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: _isLoading || _selectedBookId == null ? null : () async {
            setState(() => _isLoading = true);
            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && org != null) {
                final now = DateTime.now();
                final chatRepo = ref.read(chatRepositoryProvider);

                // 1. 채팅방 생성 + 자동 인사말
                final greeting = AutoGreetingHelper.getGreeting(
                  transactionType: 'donation',
                  bookTitle: _selectedBookTitle ?? '',
                  orgWelcomeMessage: org.welcomeMessage,
                );
                final chatRoomId = await chatRepo.createTransactionChatRoom(
                  participants: [user.uid],
                  transactionType: 'donation',
                  bookTitle: _selectedBookTitle ?? '',
                  bookId: _selectedBookId!,
                  senderUid: user.uid,
                  organizationId: widget.organizationId,
                  autoGreetingMessage: greeting,
                );

                // 2. 전달 방법 선택 카드 삽입
                await chatRepo.sendSystemMessage(
                  chatRoomId,
                  user.uid,
                  '전달 방법을 선택해주세요.',
                  type: 'delivery_select',
                );

                // 3. 기증 모델 생성
                final donation = DonationModel(
                  id: '',
                  donorUid: user.uid,
                  bookId: _selectedBookId!,
                  bookTitle: _selectedBookTitle ?? '',
                  organizationId: widget.organizationId,
                  organizationName: org.name,
                  status: 'pending',
                  message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
                  chatRoomId: chatRoomId,
                  createdAt: now,
                  updatedAt: now,
                );
                await ref.read(donationRepositoryProvider).createDonation(donation);

                // 4. 책 상태 업데이트
                await ref.read(bookRepositoryProvider).updateBook(_selectedBookId!, {'status': 'donated', 'listingType': 'donation'});

                // 5. 채팅방으로 이동
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('기증 요청 완료! 채팅에서 전달 방법을 선택하세요.')));
                  context.go(AppRoutes.chatRoomPath(chatRoomId));
                }
              }
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('요청 실패: $e')));
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('기증하기'),
        ),
        const SizedBox(height: 16),
      ])),
    );
  }
}
