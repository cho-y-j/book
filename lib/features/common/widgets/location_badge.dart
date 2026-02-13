import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class LocationBadge extends StatelessWidget {
  final String location;
  final double? distance;
  const LocationBadge({super.key, required this.location, this.distance});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 2),
      Text(location, style: AppTypography.caption),
      if (distance != null) ...[const SizedBox(width: 4), Text('${distance! < 1000 ? '${distance!.toInt()}m' : '${(distance! / 1000).toStringAsFixed(1)}km'}', style: AppTypography.caption.copyWith(color: AppColors.primary))],
    ]);
  }
}
