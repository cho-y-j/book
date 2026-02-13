import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class BookInfoPreviewCard extends StatelessWidget {
  final String title; final String author; final String? publisher; final String? coverUrl;
  const BookInfoPreviewCard({super.key, required this.title, required this.author, this.publisher, this.coverUrl});
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Row(children: [
      Container(width: 70, height: 100, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.book, color: AppColors.textSecondary)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTypography.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4), Text(author, style: AppTypography.bodySmall),
        if (publisher != null) ...[const SizedBox(height: 4), Text(publisher!, style: AppTypography.caption)],
      ])),
    ])));
  }
}
