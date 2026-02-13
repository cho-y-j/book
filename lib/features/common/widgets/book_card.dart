import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class BookCard extends StatelessWidget {
  const BookCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Row(children: [
            Container(width: 80, height: 110, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(AppDimensions.radiusSM)), child: const Icon(Icons.book, color: AppColors.textSecondary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('책 제목', style: AppTypography.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('저자', style: AppTypography.bodySmall),
              const SizedBox(height: 8),
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text('상', style: AppTypography.caption.copyWith(color: AppColors.secondary))),
                const SizedBox(width: 8),
                Text('강남구 · 직거래', style: AppTypography.caption),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.visibility_outlined, size: 14, color: AppColors.textSecondary), const SizedBox(width: 4), Text('12', style: AppTypography.caption),
                const SizedBox(width: 12),
                Icon(Icons.favorite_outline, size: 14, color: AppColors.textSecondary), const SizedBox(width: 4), Text('3', style: AppTypography.caption),
                const Spacer(), Text('2분 전', style: AppTypography.caption),
              ]),
            ])),
          ]),
        ),
      ),
    );
  }
}
