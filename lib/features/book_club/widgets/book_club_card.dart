import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class BookClubCard extends StatelessWidget {
  final String name; final String description; final int memberCount; final int maxMembers; final VoidCallback? onTap;
  const BookClubCard({super.key, required this.name, required this.description, required this.memberCount, required this.maxMembers, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: AppTypography.titleSmall),
        const SizedBox(height: 4),
        Text(description, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Row(children: [const Icon(Icons.people, size: 16, color: AppColors.textSecondary), const SizedBox(width: 4), Text('$memberCount/$maxMembers명', style: AppTypography.caption)]),
      ]))),
    );
  }
}
