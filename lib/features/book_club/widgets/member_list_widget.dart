import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

class MemberListWidget extends StatelessWidget {
  final List<String> memberNames;
  const MemberListWidget({super.key, required this.memberNames});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('멤버 (${memberNames.length}명)', style: AppTypography.labelLarge),
      const SizedBox(height: 8),
      ...memberNames.map((name) => ListTile(
        dense: true,
        leading: CircleAvatar(radius: 16, backgroundColor: AppColors.primaryLight.withOpacity(0.3), child: const Icon(Icons.person, size: 16, color: AppColors.primary)),
        title: Text(name, style: AppTypography.bodyMedium),
      )),
    ]);
  }
}
