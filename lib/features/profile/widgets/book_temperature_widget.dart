import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class BookTemperatureWidget extends StatelessWidget {
  final double temperature;
  const BookTemperatureWidget({super.key, required this.temperature});
  Color get _color { if (temperature >= 50) return AppColors.tempHot; if (temperature >= 36.5) return AppColors.tempWarm; return AppColors.tempCold; }
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text('${temperature.toStringAsFixed(1)}°C', style: AppTypography.titleLarge.copyWith(color: _color)), const SizedBox(width: 8),
        Icon(temperature >= 50 ? Icons.whatshot : temperature >= 36.5 ? Icons.thermostat : Icons.ac_unit, color: _color, size: 20)]),
      const SizedBox(height: 4), ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: temperature / 100, backgroundColor: AppColors.divider, valueColor: AlwaysStoppedAnimation(_color), minHeight: 8)),
    ]);
  }
}
