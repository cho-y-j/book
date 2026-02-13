import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class PopularBooksChart extends StatelessWidget {
  const PopularBooksChart({super.key});
  @override
  Widget build(BuildContext context) {
    final books = ['어린 왕자', '해리포터', '코스모스', '사피엔스', '데미안'];
    final counts = [45, 38, 32, 28, 24];
    return ListView.builder(itemCount: books.length, itemBuilder: (_, i) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(children: [
        SizedBox(width: 32, child: Text('${i + 1}', style: AppTypography.labelLarge.copyWith(color: i < 3 ? AppColors.accent : AppColors.textSecondary))),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(books[i], style: AppTypography.labelMedium),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: counts[i] / 50, backgroundColor: AppColors.divider, color: AppColors.primary, minHeight: 6),
        ])),
        const SizedBox(width: 8),
        Text('${counts[i]}회', style: AppTypography.caption),
      ]),
    ));
  }
}
