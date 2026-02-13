import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class ExchangeHistoryChart extends StatelessWidget {
  final Map<String, int> monthlyData;
  const ExchangeHistoryChart({super.key, required this.monthlyData});
  @override
  Widget build(BuildContext context) {
    final maxVal = monthlyData.values.isEmpty ? 1 : monthlyData.values.reduce((a, b) => a > b ? a : b);
    return SizedBox(height: 200, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: monthlyData.entries.map((e) => Expanded(
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text('${e.value}', style: AppTypography.caption),
        const SizedBox(height: 4),
        Container(height: (e.value / maxVal) * 150, decoration: BoxDecoration(color: AppColors.primary, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
        const SizedBox(height: 4),
        Text(e.key, style: AppTypography.caption.copyWith(fontSize: 10)),
      ])),
    )).toList()));
  }
}
