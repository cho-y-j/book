import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/book_providers.dart';

class RequesterBookshelfScreen extends ConsumerWidget {
  final String requesterUid;
  const RequesterBookshelfScreen({super.key, required this.requesterUid});
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
                  onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('매칭 요청 완료!'))); Navigator.pop(context); },
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
