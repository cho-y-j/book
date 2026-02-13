import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyStateWidget({super.key, required this.icon, required this.title, this.subtitle, this.actionLabel, this.onAction});
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 80, color: AppColors.divider),
      const SizedBox(height: 16),
      Text(title, style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
      if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle!, style: AppTypography.bodySmall, textAlign: TextAlign.center)],
      if (actionLabel != null && onAction != null) ...[const SizedBox(height: 24), ElevatedButton(onPressed: onAction, child: Text(actionLabel!))],
    ])));
  }
}
