import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/exchange_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../data/models/exchange_request_model.dart';

class ExchangeRequestScreen extends ConsumerStatefulWidget {
  final String targetBookId;
  const ExchangeRequestScreen({super.key, required this.targetBookId});
  @override
  ConsumerState<ExchangeRequestScreen> createState() => _ExchangeRequestScreenState();
}

class _ExchangeRequestScreenState extends ConsumerState<ExchangeRequestScreen> {
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() { _messageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookDetailProvider(widget.targetBookId));
    return Scaffold(
      appBar: AppBar(title: const Text('교환 요청')),
      body: Padding(padding: const EdgeInsets.all(AppDimensions.paddingLG), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        bookAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Text('책 정보를 불러올 수 없습니다'),
          data: (book) {
            if (book == null) return const Text('존재하지 않는 책입니다');
            return Card(child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Row(children: [
              Container(width: 60, height: 80, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.book, color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(book.title, style: AppTypography.titleMedium),
                Text(book.author, style: AppTypography.bodySmall),
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(book.condition, style: AppTypography.caption.copyWith(color: AppColors.secondary))),
              ])),
            ])));
          },
        ),
        const SizedBox(height: 24),
        Text('메시지 (선택)', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        TextFormField(controller: _messageController, decoration: const InputDecoration(hintText: '교환하고 싶은 이유나 인사말을 적어주세요'), maxLines: 4),
        const Spacer(),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            setState(() => _isLoading = true);
            try {
              final user = ref.read(currentUserProvider);
              final book = ref.read(bookDetailProvider(widget.targetBookId)).value;
              if (user != null && book != null) {
                final now = DateTime.now();
                final request = ExchangeRequestModel(
                  id: '',
                  requesterUid: user.uid,
                  ownerUid: book.ownerUid,
                  targetBookId: widget.targetBookId,
                  message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
                  status: 'pending',
                  createdAt: now,
                  updatedAt: now,
                );
                await ref.read(exchangeRepositoryProvider).createRequest(request);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('교환 요청을 보냈어요!')));
                  Navigator.pop(context);
                }
              }
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('요청 실패: $e')));
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
          child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('교환 요청 보내기'),
        ),
        const SizedBox(height: 16),
      ])),
    );
  }
}
