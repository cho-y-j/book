import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/enums.dart';

class ExchangeDifficultyBadge extends StatelessWidget {
  final ExchangeDifficulty difficulty;
  const ExchangeDifficultyBadge({super.key, required this.difficulty});
  Color get _color { switch (difficulty) { case ExchangeDifficulty.high: return AppColors.error; case ExchangeDifficulty.medium: return AppColors.warning; case ExchangeDifficulty.low: return AppColors.success; } }
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(difficulty.label, style: AppTypography.caption.copyWith(color: _color)));
  }
}
