import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  const TermsCheckbox({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Checkbox(value: value, onChanged: onChanged, activeColor: AppColors.primary),
      Expanded(child: GestureDetector(onTap: () => onChanged(!value), child: Text.rich(TextSpan(children: [
        TextSpan(text: '이용약관', style: AppTypography.bodySmall.copyWith(decoration: TextDecoration.underline, color: AppColors.primary)),
        TextSpan(text: ' 및 ', style: AppTypography.bodySmall),
        TextSpan(text: '개인정보처리방침', style: AppTypography.bodySmall.copyWith(decoration: TextDecoration.underline, color: AppColors.primary)),
        TextSpan(text: '에 동의합니다', style: AppTypography.bodySmall),
      ])))),
    ]);
  }
}
