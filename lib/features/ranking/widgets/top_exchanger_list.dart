import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class TopExchangerList extends StatelessWidget {
  const TopExchangerList({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemCount: 10, itemBuilder: (_, i) => ListTile(
      leading: CircleAvatar(backgroundColor: i < 3 ? AppColors.accent.withOpacity(0.1) : AppColors.divider,
        child: Text('${i + 1}', style: AppTypography.labelLarge.copyWith(color: i < 3 ? AppColors.accent : AppColors.textSecondary))),
      title: Text('사용자 ${i + 1}', style: AppTypography.labelLarge),
      subtitle: Text('교환 ${100 - i * 8}회', style: AppTypography.bodySmall),
      trailing: Text('${36.5 + (10 - i) * 0.5}°C', style: AppTypography.labelMedium.copyWith(color: AppColors.tempHot)),
    ));
  }
}
