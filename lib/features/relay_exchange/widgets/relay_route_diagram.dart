import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class RelayRouteDiagram extends StatelessWidget {
  final List<String> participants;
  const RelayRouteDiagram({super.key, required this.participants});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        for (int i = 0; i < participants.length; i++) ...[
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircleAvatar(radius: 24, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(participants[i][0], style: AppTypography.titleMedium.copyWith(color: AppColors.primary))),
            const SizedBox(height: 4),
            Text(participants[i], style: AppTypography.caption),
          ]),
          if (i < participants.length - 1) const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
        ],
      ]),
    );
  }
}
