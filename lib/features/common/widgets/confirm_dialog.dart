import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  const ConfirmDialog({super.key, required this.title, required this.message, this.confirmLabel = '확인', this.cancelLabel = '취소', required this.onConfirm});

  static Future<bool?> show(BuildContext context, {required String title, required String message, String confirmLabel = '확인', String cancelLabel = '취소'}) {
    return showDialog<bool>(context: context, builder: (_) => ConfirmDialog(title: title, message: message, confirmLabel: confirmLabel, cancelLabel: cancelLabel, onConfirm: () => Navigator.pop(context, true)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTypography.titleLarge),
      content: Text(message, style: AppTypography.bodyMedium),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel, style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(onPressed: onConfirm, child: Text(confirmLabel)),
      ],
    );
  }
}
