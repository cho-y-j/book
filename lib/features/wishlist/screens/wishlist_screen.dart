import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../providers/wishlist_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/wishlist_model.dart';
import '../widgets/book_alert_dialog.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  void _showAlertDialog(BuildContext context, WidgetRef ref, WishlistModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookAlertDialog(wishlist: item),
    );
  }

  void _showItemOptions(BuildContext context, WidgetRef ref, WishlistModel item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: AppColors.primary),
            title: const Text('이 책 검색하기'),
            subtitle: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.pop(ctx);
              // bookInfoId로 책 상세 검색 시도
              context.push(AppRoutes.search);
            },
          ),
          ListTile(
            leading: Icon(
              item.alertEnabled ? Icons.notifications_active : Icons.notifications_none,
              color: item.alertEnabled ? AppColors.info : AppColors.textSecondary,
            ),
            title: Text(item.alertEnabled ? '알림 설정 변경' : '알림 켜기'),
            onTap: () {
              Navigator.pop(ctx);
              _showAlertDialog(context, ref, item);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.error),
            title: Text('위시리스트에서 삭제', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              Navigator.pop(ctx);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dCtx) => AlertDialog(
                  title: const Text('삭제 확인'),
                  content: Text('"${item.title}"을(를) 위시리스트에서 삭제할까요?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('취소')),
                    TextButton(
                      onPressed: () => Navigator.pop(dCtx, true),
                      child: Text('삭제', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                ref.read(wishlistRepositoryProvider).removeWishlist(item.id);
              }
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(userWishlistsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('위시리스트')),
      body: wishlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패', style: AppTypography.bodyMedium)),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.bookmark_outline, size: 80, color: AppColors.divider),
              const SizedBox(height: 16),
              Text('위시리스트가 비어있어요', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text('관심있는 책의 하트를 눌러 추가해보세요', style: AppTypography.bodySmall),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('삭제 확인'),
                      content: Text('"${item.title}"을(를) 위시리스트에서 삭제할까요?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('취소')),
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, true),
                          child: Text('삭제', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ) ?? false;
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.error,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(wishlistRepositoryProvider).removeWishlist(item.id);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    onTap: () {
                      context.push(AppRoutes.wishlistMatches, extra: item);
                    },
                    onLongPress: () => _showItemOptions(context, ref, item),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        // 표지
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            width: 50, height: 70,
                            child: item.coverImageUrl != null && item.coverImageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(color: AppColors.divider, child: const Icon(Icons.book, size: 16, color: AppColors.textSecondary)),
                                    errorWidget: (_, __, ___) => Container(color: AppColors.divider, child: const Icon(Icons.book, size: 16, color: AppColors.textSecondary)),
                                  )
                                : Container(color: AppColors.divider, child: const Icon(Icons.book, size: 16, color: AppColors.textSecondary)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.title, style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          if (item.author.isNotEmpty)
                            Text(item.author, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(Formatters.timeAgo(item.createdAt), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                              if (item.alertEnabled) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.info.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '알림 ON',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.info,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ])),
                        // 알림 벨 아이콘
                        IconButton(
                          icon: Icon(
                            item.alertEnabled
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                            color: item.alertEnabled
                                ? AppColors.info
                                : AppColors.textSecondary,
                            size: 22,
                          ),
                          tooltip: '알림 설정',
                          onPressed: () => _showAlertDialog(context, ref, item),
                        ),
                        // 더보기 메뉴 (삭제/수정)
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                          tooltip: '더보기',
                          onPressed: () => _showItemOptions(context, ref, item),
                        ),
                      ]),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
