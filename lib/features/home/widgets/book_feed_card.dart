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

  String _listingLabel(String type) {
    switch (type) {
      case 'sale': return '판매';
      case 'both': return '교환+판매';
      default: return '교환';
    }
  }

  Color _listingColor(String type) {
    switch (type) {
      case 'sale': return Colors.orange;
      case 'both': return AppColors.primary;
      default: return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = book?.listingType ?? 'exchange';
    return Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppDimensions.radiusMD), child: Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Row(children: [
        Container(width: 80, height: 110, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
          child: book?.coverImageUrl != null && book!.coverImageUrl!.isNotEmpty
              ? ClipRRect(borderRadius: BorderRadius.circular(AppDimensions.radiusSM), child: CachedNetworkImage(imageUrl: book!.coverImageUrl!, fit: BoxFit.cover))
              : const Icon(Icons.book, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(book?.title ?? '책 제목', style: AppTypography.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(book?.author ?? '저자', style: AppTypography.bodySmall),
          const SizedBox(height: 8),
          // 거래 유형 + 상태 뱃지
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: _listingColor(listing).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(_listingLabel(listing), style: AppTypography.caption.copyWith(color: _listingColor(listing), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(Formatters.bookConditionLabel(book?.condition ?? 'good'), style: AppTypography.caption.copyWith(color: AppColors.secondary)),
            ),
            if (book?.isDealer == true) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('업자', style: AppTypography.caption.copyWith(color: Colors.purple, fontWeight: FontWeight.w600, fontSize: 10)),
              ),
            ],
          ]),
          const SizedBox(height: 8),
          // 가격 또는 교환 표시 + 통계
          Row(children: [
            if (book?.price != null && (listing == 'sale' || listing == 'both'))
              Text('${Formatters.formatPrice(book!.price!)}원', style: AppTypography.titleSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))
            else
              Text('무료 교환', style: AppTypography.bodySmall.copyWith(color: AppColors.secondary)),
            const Spacer(),
            Icon(Icons.visibility_outlined, size: 14, color: AppColors.textSecondary), const SizedBox(width: 4), Text('${book?.viewCount ?? 0}', style: AppTypography.caption),
            const SizedBox(width: 8),
            Icon(Icons.favorite_outline, size: 14, color: AppColors.textSecondary), const SizedBox(width: 4), Text('${book?.wishCount ?? 0}', style: AppTypography.caption),
          ]),
        ])),
      ]),
    )));
  }
}
