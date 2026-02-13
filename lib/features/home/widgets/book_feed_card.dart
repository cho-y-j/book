import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../data/models/book_model.dart';
import '../../../core/utils/formatters.dart';

class BookFeedCard extends StatelessWidget {
  final BookModel? book;
  final VoidCallback? onTap;
  const BookFeedCard({super.key, this.book, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppDimensions.radiusMD), child: Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Row(children: [
        Container(width: 80, height: 110, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
          child: book?.coverImageUrl != null ? ClipRRect(borderRadius: BorderRadius.circular(AppDimensions.radiusSM), child: CachedNetworkImage(imageUrl: book!.coverImageUrl!, fit: BoxFit.cover)) : const Icon(Icons.book, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(book?.title ?? '책 제목', style: AppTypography.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4), Text(book?.author ?? '저자', style: AppTypography.bodySmall),
          const SizedBox(height: 8),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(Formatters.bookConditionLabel(book?.condition ?? 'good'), style: AppTypography.caption.copyWith(color: AppColors.secondary))),
            const SizedBox(width: 8), Text(book?.location ?? '', style: AppTypography.caption),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.visibility_outlined, size: 14, color: AppColors.textSecondary), const SizedBox(width: 4), Text('${book?.viewCount ?? 0}', style: AppTypography.caption),
            const SizedBox(width: 12), Icon(Icons.favorite_outline, size: 14, color: AppColors.textSecondary), const SizedBox(width: 4), Text('${book?.wishCount ?? 0}', style: AppTypography.caption),
            const Spacer(), Text(book != null ? Formatters.timeAgo(book!.createdAt) : '', style: AppTypography.caption),
          ]),
        ])),
      ]),
    )));
  }
}
