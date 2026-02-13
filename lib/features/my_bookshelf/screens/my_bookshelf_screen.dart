import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/auth_providers.dart';

class MyBookshelfScreen extends ConsumerWidget {
  const MyBookshelfScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text('로그인이 필요합니다')));
    final booksAsync = ref.watch(userBooksProvider(uid));
    return Scaffold(
      appBar: AppBar(title: const Text('내 책장')),
      body: booksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
        data: (books) {
          if (books.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.shelves, size: 80, color: AppColors.divider),
              const SizedBox(height: 16),
              Text('아직 등록한 책이 없어요', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.go(AppRoutes.bookRegister), child: const Text('책 등록하기')),
            ]));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userBooksProvider(uid)),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemCount: books.length,
              itemBuilder: (_, i) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(width: 45, height: 60, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.book, size: 20, color: AppColors.textSecondary)),
                  title: Text(books[i].title, style: AppTypography.titleMedium),
                  subtitle: Text(books[i].condition, style: AppTypography.bodySmall),
                  trailing: PopupMenuButton(itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('수정')),
                    const PopupMenuItem(value: 'delete', child: Text('삭제')),
                  ], onSelected: (v) {
                    if (v == 'edit') context.push(AppRoutes.bookEditPath(books[i].id));
                    if (v == 'delete') {
                      ref.read(bookRepositoryProvider).deleteBook(books[i].id);
                      ref.invalidate(userBooksProvider(uid));
                    }
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
