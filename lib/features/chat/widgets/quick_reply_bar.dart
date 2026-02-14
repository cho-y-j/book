import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/quick_reply_helper.dart';

class QuickReplyBar extends StatelessWidget {
  final String? transactionType;
  final void Function(String text) onQuickReply;

  const QuickReplyBar({
    super.key,
    required this.transactionType,
    required this.onQuickReply,
  });

  @override
  Widget build(BuildContext context) {
    final templates = QuickReplyHelper.getTemplates(transactionType);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, index) {
          return ActionChip(
            label: Text(
              templates[index],
              style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
            ),
            backgroundColor: AppColors.primary.withOpacity(0.08),
            side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () => onQuickReply(templates[index]),
          );
        },
      ),
    );
  }
}
