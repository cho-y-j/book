import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/app_dimensions.dart';

class RelayRouteScreen extends StatelessWidget {
  const RelayRouteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final participants = ['참여자 A', '참여자 B', '참여자 C'];
    return Scaffold(
      appBar: AppBar(title: const Text('릴레이 교환 경로')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('교환 경로', style: AppTypography.titleMedium),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: participants.length,
              itemBuilder: (_, i) {
                final next = participants[(i + 1) % participants.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(children: [
                    CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(participants[i][participants[i].length - 1], style: AppTypography.labelLarge.copyWith(color: AppColors.primary))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(participants[i], style: AppTypography.labelLarge),
                      Text('→ $next 에게 전달', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text('대기중', style: AppTypography.caption.copyWith(color: AppColors.success)),
                    ),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
