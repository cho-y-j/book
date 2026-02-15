import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../data/models/book_model.dart';
import '../../../data/models/wishlist_model.dart';

/// Provider that fetches matched books for a wishlist item
final wishlistMatchedBooksProvider =
    FutureProvider.family<List<BookModel>, WishlistModel>((ref, wishlist) async {
  final firestore = FirebaseFirestore.instance;
  final booksRef = firestore.collection('books');
  final results = <String, BookModel>{};

  // 1. ISBN exact match
  if (wishlist.bookInfoId.isNotEmpty) {
    final snapshot = await booksRef
        .where('bookInfoId', isEqualTo: wishlist.bookInfoId)
        .where('status', isEqualTo: 'available')
        .get();
    for (final doc in snapshot.docs) {
      results[doc.id] = BookModel.fromFirestore(doc);
    }
  }

  // 2. Keyword/title prefix search
  final keyword = wishlist.searchKeyword?.isNotEmpty == true
      ? wishlist.searchKeyword!
      : wishlist.title;
  if (keyword.isNotEmpty) {
    final snapshot = await booksRef
        .where('status', isEqualTo: 'available')
        .orderBy('title')
        .startAt([keyword])
        .endAt(['$keyword\uf8ff'])
        .limit(50)
        .get();
    for (final doc in snapshot.docs) {
      results[doc.id] = BookModel.fromFirestore(doc);
    }
  }

  // Sort by createdAt descending (newest first)
  final list = results.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return list;
});

class WishlistMatchesScreen extends ConsumerWidget {
  final WishlistModel wishlist;
  const WishlistMatchesScreen({super.key, required this.wishlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(wishlistMatchedBooksProvider(wishlist));
    final keyword = wishlist.searchKeyword?.isNotEmpty == true
        ? wishlist.searchKeyword!
        : wishlist.title;

    return Scaffold(
      appBar: AppBar(
        title: Text('"$keyword" 매칭 결과'),
      ),
      body: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: AppDimensions.paddingSM),
            Text('매칭 결과를 불러올 수 없습니다', style: AppTypography.bodyMedium),
            const SizedBox(height: AppDimensions.paddingSM),
            TextButton(
              onPressed: () => ref.invalidate(wishlistMatchedBooksProvider(wishlist)),
              child: const Text('다시 시도'),
            ),
          ]),
        ),
        data: (books) {
          if (books.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search_off, size: 64, color: AppColors.divider),
                const SizedBox(height: 16),
                Text(
                  '아직 매칭된 책이 없습니다',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    '"$keyword"에 해당하는 책이 등록되면\n알림으로 알려드릴게요',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (!wishlist.alertEnabled) ...[
                  const SizedBox(height: 20),
                  Text(
                    '알림이 꺼져 있습니다. 위시리스트에서 알림을 켜주세요.',
                    style: AppTypography.caption.copyWith(color: AppColors.warning),
                    textAlign: TextAlign.center,
                  ),
                ],
              ]),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '${books.length}개의 책을 찾았어요',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
                  itemCount: books.length,
                  itemBuilder: (_, i) {
                    final book = books[i];
                    return _BookMatchCard(book: book);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookMatchCard extends StatelessWidget {
  final BookModel book;
  const _BookMatchCard({required this.book});

  String _conditionLabel(String condition) {
    switch (condition) {
      case 'best':
        return '최상';
      case 'good':
        return '상';
      case 'fair':
        return '중';
      case 'poor':
        return '하';
      default:
        return condition;
    }
  }

  String _listingTypeLabel(String type) {
    switch (type) {
      case 'exchange':
        return '교환';
      case 'sale':
        return '판매';
      case 'both':
        return '교환/판매';
      case 'sharing':
        return '나눔';
      case 'donation':
        return '기증';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        onTap: () => context.push(AppRoutes.bookDetailPath(book.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            // Cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 55,
                height: 75,
                child: book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: book.coverImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.divider,
                          child: const Icon(Icons.book, size: 20, color: AppColors.textSecondary),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.divider,
                          child: const Icon(Icons.book, size: 20, color: AppColors.textSecondary),
                        ),
                      )
                    : Container(
                        color: AppColors.divider,
                        child: const Icon(Icons.book, size: 20, color: AppColors.textSecondary),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  book.title,
                  style: AppTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (book.author.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(spacing: 6, children: [
                  _Chip(label: _conditionLabel(book.condition)),
                  _Chip(label: _listingTypeLabel(book.listingType)),
                  if (book.price != null)
                    _Chip(label: '${book.price!.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}원'),
                ]),
              ]),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ]),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: AppColors.primary, fontSize: 11),
      ),
    );
  }
}
