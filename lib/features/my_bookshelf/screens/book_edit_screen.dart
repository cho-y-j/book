import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../providers/book_providers.dart';

class BookEditScreen extends ConsumerStatefulWidget {
  final String bookId;
  const BookEditScreen({super.key, required this.bookId});
  @override
  ConsumerState<BookEditScreen> createState() => _BookEditScreenState();
}

class _BookEditScreenState extends ConsumerState<BookEditScreen> {
  BookCondition _condition = BookCondition.good;
  final _noteController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() { _noteController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookDetailProvider(widget.bookId));

    if (!_initialized && bookAsync.value != null) {
      final book = bookAsync.value!;
      try { _condition = BookCondition.values.firstWhere((c) => c.name == book.condition); } catch (_) {}
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('책 수정'), actions: [
        TextButton(onPressed: () async {
          await ref.read(bookRepositoryProvider).updateBook(widget.bookId, {'condition': _condition.name, 'conditionNote': _noteController.text.trim()});
          ref.invalidate(bookDetailProvider(widget.bookId));
          if (mounted) Navigator.pop(context);
        }, child: Text('저장', style: TextStyle(color: AppColors.primary))),
      ]),
      body: Padding(padding: const EdgeInsets.all(AppDimensions.paddingLG), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('책 상태 수정', style: AppTypography.titleMedium),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: BookCondition.values.map((c) => ChoiceChip(
          label: Text(c.label), selected: _condition == c,
          selectedColor: AppColors.primaryLight,
          onSelected: (_) => setState(() => _condition = c),
        )).toList()),
        const SizedBox(height: 24),
        TextFormField(controller: _noteController, decoration: const InputDecoration(labelText: '상태 메모'), maxLines: 2),
      ])),
    );
  }
}
