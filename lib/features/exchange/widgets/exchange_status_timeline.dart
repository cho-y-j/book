import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class ExchangeStatusTimeline extends StatelessWidget {
  final int currentStep;
  const ExchangeStatusTimeline({super.key, required this.currentStep});
  static const _steps = ['요청', '매칭', '거래중', '완료'];
  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(_steps.length * 2 - 1, (i) {
      if (i.isOdd) return Expanded(child: Container(height: 2, color: i ~/ 2 < currentStep ? AppColors.primary : AppColors.divider));
      final step = i ~/ 2;
      final isActive = step <= currentStep;
      return Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(radius: 14, backgroundColor: isActive ? AppColors.primary : AppColors.divider, child: isActive ? const Icon(Icons.check, size: 14, color: Colors.white) : Text('${step + 1}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        const SizedBox(height: 4), Text(_steps[step], style: AppTypography.caption.copyWith(color: isActive ? AppColors.primary : AppColors.textSecondary)),
      ]);
    }));
  }
}
