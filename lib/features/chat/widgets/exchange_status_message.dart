import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class ExchangeStatusMessage extends StatelessWidget {
  final String message;
  const ExchangeStatusMessage({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Text(message, style: AppTypography.caption.copyWith(color: AppColors.info))));
  }
}
