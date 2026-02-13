import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class GenreDistributionChart extends StatelessWidget {
  final Map<String, int> data;
  const GenreDistributionChart({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    final maxVal = data.values.isEmpty ? 1 : data.values.reduce((a, b) => a > b ? a : b);
    return Column(children: data.entries.map((e) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 60, child: Text(e.key, style: AppTypography.caption)),
        Expanded(child: LinearProgressIndicator(value: e.value / maxVal, backgroundColor: AppColors.divider, color: AppColors.primary, minHeight: 8)),
        const SizedBox(width: 8),
        Text('${e.value}권', style: AppTypography.caption),
      ]),
    )).toList());
  }
}
