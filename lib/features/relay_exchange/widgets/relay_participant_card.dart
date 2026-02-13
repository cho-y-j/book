import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class RelayParticipantCard extends StatelessWidget {
  final String name; final String bookTitle; final int order;
  const RelayParticipantCard({super.key, required this.name, required this.bookTitle, required this.order});
  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(
      leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Text('$order', style: AppTypography.labelLarge.copyWith(color: AppColors.primary))),
      title: Text(name, style: AppTypography.labelLarge),
      subtitle: Text(bookTitle, style: AppTypography.bodySmall),
    ));
  }
}
