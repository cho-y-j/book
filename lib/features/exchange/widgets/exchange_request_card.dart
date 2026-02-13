import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class ExchangeRequestCard extends StatelessWidget {
  final String requesterName; final String bookTitle; final String timeAgo;
  final VoidCallback onAccept; final VoidCallback onReject; final VoidCallback onViewBookshelf;
  const ExchangeRequestCard({super.key, required this.requesterName, required this.bookTitle, required this.timeAgo, required this.onAccept, required this.onReject, required this.onViewBookshelf});
  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [CircleAvatar(radius: 20, backgroundColor: AppColors.primaryLight.withOpacity(0.3), child: const Icon(Icons.person, color: AppColors.primary, size: 20)),
        const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(requesterName, style: AppTypography.titleMedium), Text(timeAgo, style: AppTypography.caption)])),
      ]),
      const SizedBox(height: 12), Text('"$bookTitle" 교환을 원합니다', style: AppTypography.bodyMedium),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: OutlinedButton(onPressed: onReject, child: const Text('거절'))), const SizedBox(width: 8), Expanded(child: ElevatedButton(onPressed: onViewBookshelf, child: const Text('책장 보기')))]),
    ])));
  }
}
