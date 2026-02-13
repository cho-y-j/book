import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/services/level_badge_service.dart';

class BadgeGrid extends StatelessWidget {
  final List<String> badges;
  const BadgeGrid({super.key, required this.badges});
  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 12, runSpacing: 12, children: badges.map((b) => Column(children: [
      Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.2), shape: BoxShape.circle),
        child: Center(child: Text(LevelBadgeService.badgeEmoji(b), style: const TextStyle(fontSize: 24)))),
      const SizedBox(height: 4), Text(LevelBadgeService.badgeDisplayName(b), style: AppTypography.caption),
    ])).toList());
  }
}
