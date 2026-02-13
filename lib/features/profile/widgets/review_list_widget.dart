import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class ReviewListWidget extends StatelessWidget {
  const ReviewListWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 3, itemBuilder: (_, i) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [CircleAvatar(radius: 16, backgroundColor: AppColors.primaryLight.withOpacity(0.3), child: const Icon(Icons.person, size: 16, color: AppColors.primary)),
          const SizedBox(width: 8), Text('사용자 ${i + 1}', style: AppTypography.labelLarge),
          const Spacer(), Row(children: List.generate(5, (j) => Icon(j < 4 ? Icons.star : Icons.star_border, size: 16, color: AppColors.warning)))]),
        const SizedBox(height: 8), Text('좋은 거래였어요! 책 상태도 설명과 동일합니다.', style: AppTypography.bodyMedium),
        const SizedBox(height: 8), Wrap(spacing: 4, children: ['빠른 응답', '상태 정확'].map((t) => Chip(label: Text(t, style: AppTypography.caption), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact)).toList()),
      ])),
    ));
  }
}
