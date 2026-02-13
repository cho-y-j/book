import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/book_providers.dart';
import '../../../providers/auth_providers.dart';

class MyBookshelfScreen extends ConsumerWidget {
  const MyBookshelfScreen({super.key});

  String _statusLabel(String status) {
    switch (status) {
      case 'available': return '교환가능';
      case 'reserved': return '예약중';
      case 'exchanged': return '교환완료';
      case 'hidden': return '숨김';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available': return AppColors.success;
      case 'reserved': return AppColors.warning;
      case 'exchanged': return AppColors.textSecondary;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserProvider)?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text('로그인이 필요합니다')));
    final booksAsync = ref.watch(userBooksProvider(uid));
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 책장'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.bookRegister),
          ),
        ],
      ),
      body: booksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
        data: (books) {
          if (books.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.shelves, size: 80, color: AppColors.divider),
              const SizedBox(height: 16),
              Text('아직 등록한 책이 없어요', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text('첫 번째 책을 등록해보세요!', style: AppTypography.bodySmall),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.bookRegister),
                icon: const Icon(Icons.add),
                label: const Text('책 등록하기'),
              ),
            ]));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userBooksProvider(uid)),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemCount: books.length,
              itemBuilder: (_, i) {
                final book = books[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    onTap: () => context.push(AppRoutes.bookDetailPath(book.id)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        // 표지 이미지
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            width: 55, height: 75,
                            child: book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: book.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: AppColors.divider, child: const Icon(Icons.book, size: 20, color: AppColors.textSecondary)),
                                    errorWidget: (_, __, ___) => Container(color: AppColors.divider, child: const Icon(Icons.book, size: 20, color: AppColors.textSecondary)),
                                  )
                                : Container(color: AppColors.divider, child: const Icon(Icons.book, size: 20, color: AppColors.textSecondary)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 정보
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(book.title, style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(book.author, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          // 상태 배지
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusColor(book.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _statusLabel(book.status),
                              style: AppTypography.caption.copyWith(
                                color: _statusColor(book.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ])),
                        // 메뉴
                        PopupMenuButton(itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [
                            Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('수정'),
                          ])),
                          PopupMenuItem(value: 'hide', child: Row(children: [
                            Icon(book.status == 'hidden' ? Icons.visibility : Icons.visibility_off, size: 18),
                            const SizedBox(width: 8),
                            Text(book.status == 'hidden' ? '게시하기' : '가리기'),
                          ])),
                          const PopupMenuItem(value: 'bump', child: Row(children: [
                            Icon(Icons.arrow_upward, size: 18), SizedBox(width: 8), Text('끌어올리기'),
                          ])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('삭제', style: TextStyle(color: AppColors.error)),
                          ])),
                        ], onSelected: (v) {
                          final repo = ref.read(bookRepositoryProvider);
                          if (v == 'edit') {
                            context.push(AppRoutes.bookEditPath(book.id));
                          } else if (v == 'hide') {
                            final willHide = book.status != 'hidden';
                            repo.toggleHideBook(book.id, willHide);
                            ref.invalidate(userBooksProvider(uid));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(willHide ? '게시물을 가렸습니다' : '게시물을 다시 게시합니다'),
                            ));
                          } else if (v == 'bump') {
                            repo.bumpBook(book.id);
                            ref.invalidate(userBooksProvider(uid));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('끌어올리기 완료! 목록 상단에 노출됩니다'), backgroundColor: AppColors.success),
                            );
                          } else if (v == 'delete') {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('책 삭제'),
                                content: Text('"${book.title}"을(를) 삭제하시겠습니까?\n삭제 후 복구할 수 없습니다.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      repo.deleteBook(book.id);
                                      ref.invalidate(userBooksProvider(uid));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('삭제되었습니다')),
                                      );
                                    },
                                    child: Text('삭제', style: TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            );
                          }
                        }),
                      ]),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
