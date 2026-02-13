import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class ActivityStatsCard extends StatelessWidget {
  final double temperature; final int totalExchanges; final int level;
  const ActivityStatsCard({super.key, required this.temperature, required this.totalExchanges, required this.level});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(AppDimensions.paddingMD), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _Stat(label: '온도', value: '${temperature.toStringAsFixed(1)}°C'),
        _Stat(label: '교환', value: '${totalExchanges}회'),
        _Stat(label: '레벨', value: 'Lv.$level'),
      ]));
  }
}

class _Stat extends StatelessWidget {
  final String label; final String value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) { return Column(children: [Text(value, style: AppTypography.titleLarge.copyWith(color: AppColors.primary)), const SizedBox(height: 4), Text(label, style: AppTypography.caption)]); }
}
