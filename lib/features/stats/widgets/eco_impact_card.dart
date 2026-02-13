import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class EcoImpactCard extends StatelessWidget {
  final String title; final String value; final IconData icon;
  const EcoImpactCard({super.key, required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Icon(icon, color: AppColors.secondary, size: 32),
      const SizedBox(height: 8),
      Text(value, style: AppTypography.headlineSmall.copyWith(color: AppColors.secondary)),
      const SizedBox(height: 4),
      Text(title, style: AppTypography.caption),
    ])));
  }
}
