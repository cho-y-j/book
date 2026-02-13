import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';
import 'star_rating_widget.dart';

class ReviewCard extends StatelessWidget {
  final String reviewerName; final double rating; final String? comment; final List<String> tags; final String timeAgo;
  const ReviewCard({super.key, required this.reviewerName, required this.rating, this.comment, this.tags = const [], required this.timeAgo});
  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [CircleAvatar(radius: 16, backgroundColor: AppColors.primaryLight.withOpacity(0.3), child: const Icon(Icons.person, size: 16, color: AppColors.primary)),
        const SizedBox(width: 8), Text(reviewerName, style: AppTypography.labelLarge), const Spacer(), StarRatingWidget(rating: rating, size: 16)]),
      if (comment != null) ...[const SizedBox(height: 8), Text(comment!, style: AppTypography.bodyMedium)],
      if (tags.isNotEmpty) ...[const SizedBox(height: 8), Wrap(spacing: 4, children: tags.map((t) => Chip(label: Text(t, style: AppTypography.caption), visualDensity: VisualDensity.compact)).toList())],
      const SizedBox(height: 4), Text(timeAgo, style: AppTypography.caption),
    ])));
  }
}
