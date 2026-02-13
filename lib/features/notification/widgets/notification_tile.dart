import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class NotificationTile extends StatelessWidget {
  final String title; final String body; final String timeAgo; final bool isRead; final VoidCallback? onTap;
  const NotificationTile({super.key, required this.title, required this.body, required this.timeAgo, this.isRead = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: isRead ? null : AppColors.primaryLight.withOpacity(0.05),
      leading: CircleAvatar(radius: 20, backgroundColor: isRead ? AppColors.divider : AppColors.primary.withOpacity(0.1), child: Icon(Icons.notifications, color: isRead ? AppColors.textSecondary : AppColors.primary, size: 20)),
      title: Text(title, style: AppTypography.labelLarge.copyWith(fontWeight: isRead ? FontWeight.normal : FontWeight.w600)),
      subtitle: Text(body, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(timeAgo, style: AppTypography.caption),
      onTap: onTap,
    );
  }
}
