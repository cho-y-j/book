import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const AppErrorWidget({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
      const SizedBox(height: 16),
      Text(message, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
      if (onRetry != null) ...[const SizedBox(height: 16), ElevatedButton(onPressed: onRetry, child: const Text('다시 시도'))],
    ])));
  }
}
