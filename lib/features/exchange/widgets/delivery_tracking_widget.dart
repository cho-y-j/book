import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class DeliveryTrackingWidget extends StatelessWidget {
  final String? carrier; final String? trackingNumber; final String status;
  const DeliveryTrackingWidget({super.key, this.carrier, this.trackingNumber, required this.status});
  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(AppDimensions.paddingMD), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.local_shipping, color: AppColors.primary), const SizedBox(width: 8), Text('배송 현황', style: AppTypography.titleMedium)]),
      const SizedBox(height: 12),
      if (carrier != null) Text('택배사: $carrier', style: AppTypography.bodyMedium),
      if (trackingNumber != null) Text('운송장: $trackingNumber', style: AppTypography.bodyMedium),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(status, style: AppTypography.bodySmall.copyWith(color: AppColors.info))),
    ])));
  }
}
