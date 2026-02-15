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
                    onTap: () => context.push(AppRoutes.search),
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
                        Icon(Icons.favorite, color: AppColors.error, size: 20),
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
