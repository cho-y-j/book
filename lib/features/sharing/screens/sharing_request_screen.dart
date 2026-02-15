import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/sharing_request_model.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/sharing_providers.dart';

class SharingRequestScreen extends ConsumerStatefulWidget {
  final String bookId;
  const SharingRequestScreen({super.key, required this.bookId});
  @override
  ConsumerState<SharingRequestScreen> createState() => _SharingRequestScreenState();
}

class _SharingRequestScreenState extends ConsumerState<SharingRequestScreen> {
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
        final request = SharingRequestModel(
          id: '',
          requesterUid: user.uid,
          ownerUid: book.ownerUid,
          bookId: widget.bookId,
          bookTitle: book.title,
          status: 'pending',
          message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await ref.read(sharingRepositoryProvider).createSharingRequest(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('나눔 요청을 보냈어요!')));
          Navigator.pop(context);
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
      appBar: AppBar(title: const Text('나눔 요청')),
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
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text('무료 나눔', style: AppTypography.caption.copyWith(color: Colors.green, fontWeight: FontWeight.w600)),
                  ),
                ])),
              ])));
            },
          ),
          const SizedBox(height: 24),
          Text('메시지 (선택)', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(hintText: '나눔 요청 메시지를 적어주세요'),
            maxLines: 4,
          ),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('나눔 요청하기'),
          ),
        ),
      ),
    );
  }
}
