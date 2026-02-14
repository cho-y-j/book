import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/admin_providers.dart';
import '../../../data/models/book_model.dart';

/// 어드민 책 관리 화면
/// - 상태별 필터링 (전체/교환가능/판매완료/숨김)
/// - 책 목록 표시 (커버, 제목, 저자, 등록 유형, 가격, 소유자, 상태)
/// - 길게 누르거나 trailing 아이콘으로 삭제
class AdminBookListScreen extends ConsumerStatefulWidget {
  const AdminBookListScreen({super.key});

  @override
  ConsumerState<AdminBookListScreen> createState() =>
      _AdminBookListScreenState();
}

class _AdminBookListScreenState extends ConsumerState<AdminBookListScreen> {
  String? _selectedStatus;

  static const _statusFilters = <String?, String>{
    null: '전체',
    'available': '교환가능',
    'sold': '판매완료',
    'hidden': '숨김',
  };

  String _listingTypeLabel(String type) {
    switch (type) {
      case 'sale':
        return '판매';
      case 'both':
        return '교환+판매';
      case 'exchange':
      default:
        return '교환';
    }
  }

  Color _listingTypeBadgeColor(String type) {
    switch (type) {
      case 'sale':
        return AppColors.accent;
      case 'both':
        return AppColors.info;
      case 'exchange':
      default:
        return AppColors.secondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'available':
        return '교환가능';
      case 'reserved':
        return '예약중';
      case 'exchanged':
        return '교환완료';
      case 'sold':
        return '판매완료';
      case 'hidden':
        return '숨김';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.success;
      case 'reserved':
        return AppColors.warning;
      case 'exchanged':
        return AppColors.info;
      case 'sold':
        return AppColors.primary;
      case 'hidden':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showDeleteDialog(BookModel book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('책 삭제'),
        content: Text(
          '"${book.title}"을(를) 삭제하시겠습니까?\n\n'
          '소유자: ${book.ownerUid}\n'
          '삭제 후 복구할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(adminRepositoryProvider)
                    .deleteBook(book.id);
                ref.invalidate(allBooksAdminProvider(_selectedStatus));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('삭제되었습니다'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 실패: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(allBooksAdminProvider(_selectedStatus));

    return Scaffold(
      appBar: AppBar(title: const Text('책 관리')),
      body: Column(
        children: [
          // --- Filter chips ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMD,
              vertical: AppDimensions.paddingSM,
            ),
            child: Row(
              children: _statusFilters.entries.map((entry) {
                final isSelected = _selectedStatus == entry.key;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.paddingSM),
                  child: FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedStatus = entry.key);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // --- Book list ---
          Expanded(
            child: booksAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: AppDimensions.paddingSM),
                    Text(
                      '책 목록을 불러올 수 없습니다',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppDimensions.paddingSM),
                    TextButton(
                      onPressed: () => ref.invalidate(
                          allBooksAdminProvider(_selectedStatus)),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
              data: (books) {
                if (books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book,
                            size: 80, color: AppColors.divider),
                        const SizedBox(height: AppDimensions.paddingMD),
                        Text(
                          '등록된 책이 없습니다',
                          style: AppTypography.bodyLarge
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allBooksAdminProvider(_selectedStatus));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingSM),
                    itemCount: books.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 88),
                    itemBuilder: (_, index) {
                      final book = books[index];
                      return _BookListTile(
                        book: book,
                        statusLabel: _statusLabel(book.status),
                        statusColor: _statusColor(book.status),
                        listingTypeLabel: _listingTypeLabel(book.listingType),
                        listingTypeBadgeColor:
                            _listingTypeBadgeColor(book.listingType),
                        onDelete: () => _showDeleteDialog(book),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookListTile extends StatelessWidget {
  final BookModel book;
  final String statusLabel;
  final Color statusColor;
  final String listingTypeLabel;
  final Color listingTypeBadgeColor;
  final VoidCallback onDelete;

  const _BookListTile({
    required this.book,
    required this.statusLabel,
    required this.statusColor,
    required this.listingTypeLabel,
    required this.listingTypeBadgeColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onDelete,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingSM,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Cover thumbnail ---
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusSM),
              child: SizedBox(
                width: 56,
                height: 76,
                child: book.coverImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: book.coverImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.divider,
                          child: const Icon(Icons.book,
                              size: 24, color: AppColors.textSecondary),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.divider,
                          child: const Icon(Icons.broken_image,
                              size: 24, color: AppColors.textSecondary),
                        ),
                      )
                    : Container(
                        color: AppColors.divider,
                        child: const Icon(Icons.book,
                            size: 24, color: AppColors.textSecondary),
                      ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSM),

            // --- Book info ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.title,
                    style: AppTypography.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Author
                  Text(
                    book.author,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),

                  // Listing type badge + Status badge
                  Row(
                    children: [
                      _Badge(
                        label: listingTypeLabel,
                        color: listingTypeBadgeColor,
                      ),
                      const SizedBox(width: AppDimensions.paddingXS),
                      _Badge(
                        label: statusLabel,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),

                  // Price + Owner UID
                  Row(
                    children: [
                      if (book.price != null) ...[
                        Text(
                          '${Formatters.formatPrice(book.price!)}원',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingSM),
                      ],
                      Expanded(
                        child: Text(
                          'UID: ${book.ownerUid}',
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Delete trailing icon ---
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.error,
              onPressed: onDelete,
              tooltip: '삭제',
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM / 2),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
