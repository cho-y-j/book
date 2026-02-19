import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/auto_greeting_helper.dart';
import '../../../data/models/purchase_request_model.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/purchase_providers.dart';
import '../../../providers/chat_providers.dart';

class PurchaseRequestScreen extends ConsumerStatefulWidget {
  final String bookId;
  const PurchaseRequestScreen({super.key, required this.bookId});
  @override
  ConsumerState<PurchaseRequestScreen> createState() => _PurchaseRequestScreenState();
}

class _PurchaseRequestScreenState extends ConsumerState<PurchaseRequestScreen> {
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() { _messageController.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final book = ref.read(bookDetailProvider(widget.bookId)).value;
      if (user != null && book != null) {
        final now = DateTime.now();
        final request = PurchaseRequestModel(
          id: '',
          buyerUid: user.uid,
          sellerUid: book.ownerUid,
          bookId: widget.bookId,
          bookTitle: book.title,
          price: book.price ?? 0,
          message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
          status: 'pending',
          createdAt: now,
          updatedAt: now,
        );
        final requestId = await ref.read(purchaseRepositoryProvider).createPurchaseRequest(request);
        // 즉시 채팅방 생성 → 구매자가 채팅 목록에서 바로 확인 가능
        final greeting = AutoGreetingHelper.getGreeting(
          transactionType: 'sale',
          bookTitle: book.title,
          price: book.price ?? 0,
        );
        final chatRoomId = await ref.read(chatRepositoryProvider).createTransactionChatRoom(
          participants: [book.ownerUid, user.uid],
          transactionType: 'sale',
          bookTitle: book.title,
          bookId: widget.bookId,
          senderUid: user.uid,
          autoGreetingMessage: greeting,
        );
        // 구매 요청에 chatRoomId 연결
        await ref.read(purchaseRepositoryProvider).updateChatRoomId(requestId, chatRoomId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('구매 요청을 보냈어요!')));
          context.push(AppRoutes.chatRoomPath(chatRoomId));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('요청 실패: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookDetailProvider(widget.bookId));
    return Scaffold(
      appBar: AppBar(title: const Text('구매 요청')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          bookAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text('책 정보를 불러올 수 없습니다'),
            data: (book) {
              if (book == null) return const Text('존재하지 않는 책입니다');
              return Card(child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Row(children: [
                Container(
                  width: 60, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.divider, borderRadius: BorderRadius.circular(8),
                    image: book.coverImageUrl != null
                        ? DecorationImage(image: NetworkImage(book.coverImageUrl!), fit: BoxFit.cover) : null,
                  ),
                  child: book.coverImageUrl == null ? const Icon(Icons.book, color: AppColors.textSecondary) : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(book.title, style: AppTypography.titleMedium),
                  Text(book.author, style: AppTypography.bodySmall),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(Formatters.bookConditionLabel(book.condition), style: AppTypography.caption.copyWith(color: AppColors.secondary)),
                  ),
                  const SizedBox(height: 8),
                  Text('${Formatters.formatPrice(book.price ?? 0)}원', style: AppTypography.titleLarge.copyWith(color: AppColors.accent)),
                ])),
              ])));
            },
          ),
          const SizedBox(height: 24),
          Text('메시지 (선택)', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(hintText: '판매자에게 전할 메시지를 적어주세요'),
            maxLines: 4,
          ),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('구매 요청하기'),
          ),
        ),
      ),
    );
  }
}
