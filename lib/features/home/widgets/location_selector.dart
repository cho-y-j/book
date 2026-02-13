import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class LocationSelector extends StatelessWidget {
  final String currentLocation;
  final ValueChanged<String> onLocationChanged;
  const LocationSelector({super.key, required this.currentLocation, required this.onLocationChanged});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [
      const Icon(Icons.location_on, color: AppColors.primary, size: 20),
      const SizedBox(width: 4),
      Text(currentLocation, style: AppTypography.titleMedium),
      const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
    ]));
  }
}
